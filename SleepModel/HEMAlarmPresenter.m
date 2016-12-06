//
//  HEMAlarmPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSound.h>
#import <SenseKit/SENExpansion.h>

#import "UIBarButtonItem+HEMNav.h"

#import "HEMAlarmPresenter.h"
#import "HEMAlarmService.h"
#import "HEMStyle.h"
#import "HEMAlarmCache.h"
#import "HEMTutorial.h"
#import "HEMClockPickerView.h"
#import "HEMMainStoryboard.h"
#import "HEMExpansionService.h"
#import "HEMAlarmTableViewCell.h"
#import "HEMActivityCoverView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAlarmExpansionSetupPresenter.h"
#import "HEMDeviceService.h"

static CGFloat const HEMAlarmPresenterSuccessDelay = 0.8f;
static CGFloat const HEMAlarmConfigCellHeight = 66.0f;
static CGFloat const HEMAlarmTimePickerMinHeight = 287.0f;
static CGFloat const HEMAlarmConfigCellLightAccessoryPadding = 12.0f;
static NSInteger const HEMAlarmConfigCellExpansionMaskTag = 11;
static CGFloat const HEMAlarmConfigCellMaskAlpha = 0.7f;

@interface HEMAlarmPresenter() <
    UITableViewDataSource,
    UITableViewDelegate,
    HEMClockPickerViewDelegate,
    HEMAlarmExpansionSetupDelegate
>

@property (nonatomic, weak) HEMAlarmService* service;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) UIViewController* tutorialPresenter;
@property (nonatomic, strong) HEMAlarmCache* cache;
@property (nonatomic, strong) HEMAlarmCache* originalAlarm;
@property (nonatomic, weak) SENAlarm* alarm;
@property (nonatomic, assign) BOOL configuredClockPicker;
@property (nonatomic, assign) BOOL deletingAlarm;
@property (nonatomic, strong) HEMActivityCoverView* activityView;
@property (nonatomic, strong) NSArray<NSNumber*>* rows;
@property (nonatomic, assign, getter=isLoadingExpansions) BOOL loadingExpansions;
@property (nonatomic, strong) NSArray<SENExpansion*>* expansions;
@property (nonatomic, assign) BOOL reloadExpansionsWhenBack;

@end

@implementation HEMAlarmPresenter

- (instancetype)initWithAlarm:(SENAlarm*)alarm
                 alarmService:(HEMAlarmService*)alarmService
                deviceService:(HEMDeviceService*)deviceService
             expansionService:(HEMExpansionService*)expansionService {
    self = [super init];
    if (self) {
        _alarm = alarm;
        _service = alarmService;
        _deviceService = deviceService;
        _expansionService = expansionService;
        _cache = [HEMAlarmCache new];
        _originalAlarm = [HEMAlarmCache new];
        
        if (_alarm) {
            [_cache cacheValuesFromAlarm:_alarm];
            [_originalAlarm cacheValuesFromAlarm:_alarm];
        }
        
        if (![_service hasLoadedAlarms]) {
            [_service refreshAlarms:nil];
        } else {
            [self setDefaultsForAlarm:_cache];
        }
        
        NSMutableArray* rows = [NSMutableArray arrayWithCapacity:6];
        [rows addObjectsFromArray:@[@(HEMAlarmRowTypeSmart),
                                    @(HEMAlarmRowTypeTone),
                                    @(HEMAlarmRowTypeRepeat)]];
        
        // Sense Voice only features
        if ([_deviceService savedHardwareVersion] == SENSenseHardwareVoice) {
            [rows addObject:@(HEMAlarmRowTypeLight)];
            [rows addObject:@(HEMAlarmRowTypeThermostat)];
        }
        
        // Optionally show delete
        if ([alarm isSaved]) {
            [rows addObject:@(HEMAlarmRowTypeDelete)];
        }
        
        _rows = rows;
    }
    return self;
}

- (void)setDefaultsForAlarm:(HEMAlarmCache*)alarmCache {
    if (![[self alarm] isSaved]) {
        SENAlarmRepeatDays days = [alarmCache repeatFlags];
        if (![alarmCache isRepeated]) {
            days = [[self service] dayForNonRepeatingAlarmWithHour:[alarmCache hour]
                                                            minute:[alarmCache minute]];
        }
        [alarmCache setSmart:[[self service] canAddRepeatDay:days
                                                          to:alarmCache
                                                   excluding:[self alarm]]];
    }
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    NSString* cancelText = NSLocalizedString(@"actions.cancel", nil);
    UIBarButtonItem* cancelItem = [UIBarButtonItem cancelItemWithTitle:cancelText
                                                                 image:nil
                                                                target:self
                                                                action:@selector(cancel)];
    
    UIBarButtonItem* saveItem = [UIBarButtonItem saveButtonWithTarget:self action:@selector(save)];
    
    [navItem setLeftBarButtonItem:cancelItem];
    [navItem setRightBarButtonItem:saveItem];
    [navItem setTitle:NSLocalizedString(@"alarm.edit.title", nil)];
}

- (void)bindWithTableView:(UITableView*)tableView {
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorColor:[UIColor separatorColor]];
    [tableView setTableFooterView:[UIView new]];
    [tableView setBounces:YES];
    
    HEMClockPickerView* timePicker = (id) [tableView tableHeaderView];
    [timePicker setDelegate:self];
    
    [self setTableView:tableView];
    [self reloadWithAlarmSoundMetadata];
    
    if ([[self rows] containsObject:@(HEMAlarmRowTypeLight)]) {
        [self loadExpansions:nil];
    }
}

- (void)reloadWithAlarmSoundMetadata {
    // if the alarm / cache already has a sound set, skip this
    if ([[self cache] soundID]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[self service] loadAvailableAlarmSounds:^(NSArray<SENSound *> * _Nullable sounds, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error && [sounds count] > 0) {
            SENSound* sound = [sounds firstObject];
            [[strongSelf cache] setSoundID:[sound identifier]];
            [[strongSelf cache] setSoundName:[sound displayName]];
            [[strongSelf tableView] reloadData];
        }
    }];
}

- (void)bindWithTutorialPresentingController:(UIViewController*)controller {
    [self setTutorialPresenter:controller];
}

#pragma mark - Expansions

- (void)loadExpansions:(void(^)(void))completion {
    [self setLoadingExpansions:YES];
    __weak typeof(self) weakSelf = self;
    [[self expansionService] getListOfExpansion:^(NSArray<SENExpansion *> * expansions, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setExpansions:expansions];
        [strongSelf setLoadingExpansions:NO];
        [[strongSelf tableView] reloadData];
    }];
}

#pragma mark - Activity

- (void)showAlarmActivity:(void(^)(void))completion {
    if ([self activityView]) {
        [[self activityView] removeFromSuperview];
    }
    
    UIView* parentView = [[self delegate] activityContainerFor:self];
    NSString* activityText = NSLocalizedString(@"activity.saving.changes", nil);
    [self setActivityView:[HEMActivityCoverView new]];
    [[self activityView] showInView:parentView
                           withText:activityText
                           activity:YES
                         completion:completion];
}

- (void)hideAlarmActivity:(BOOL)success completion:(void(^)(void))completion {
    if ([[self activityView] isShowing]) {
        NSString* message = [self successText];
        if (success && !message) {
            message = [self deletingAlarm]
                    ? NSLocalizedString(@"actions.deleted", nil)
                    : NSLocalizedString(@"actions.saved", nil);
        }
        
        if (success) {
            UIImage* check = [UIImage imageNamed:@"check"];
            [[[self activityView] indicator] setHidden:YES];
            [[self activityView] updateText:message successIcon:check hideActivity:YES completion:^(BOOL finished) {
                [[self activityView] showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                    CGFloat duration = [self successDuration] > 0
                                     ? [self successDuration]
                                     : HEMAlarmPresenterSuccessDelay;
                    int64_t delayInSecs = (int64_t)(duration * NSEC_PER_SEC);
                    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
                    dispatch_after(delay, dispatch_get_main_queue(), completion);
                }];
            }];
        } else {
            [[self activityView] dismissWithResultText:nil
                                       showSuccessMark:NO
                                                remove:YES
                                            completion:completion];
        }
    } else {
        completion ();
    }
}

#pragma mark - Actions

- (void)cancel {
    [[self delegate] didSave:NO from:self];
}

- (void)save {
    BOOL tooSoon = [[self service] isTimeTooSoon:[self cache]];
    BOOL willRingToday = [[self service] willRingToday:[self cache]];
    if (tooSoon && willRingToday) {
        NSString* title = NSLocalizedString(@"alarm.save-error.too-soon.title", nil);
        NSString* message = NSLocalizedString(@"alarm.save-error.too-soon.message", nil);
        [[self delegate] showErrorWithTitle:title message:message from:self];
        return;
    }
    
    [self setDeletingAlarm:NO];
    [[self cache] setOn:YES];
    [[self service] copyCache:[self cache] to:[self alarm]];
    
    NSMutableArray* updatedAlarms = nil;
    NSArray* alarms = [[self service] alarms];
    if (![[self alarm] isSaved]) {
        updatedAlarms = alarms ? [alarms mutableCopy] : [NSMutableArray array];
        [updatedAlarms addObject:[self alarm]];
    }
    
    [self showAlarmActivity:^{
        __weak typeof(self) weakSelf = self;
        [[self service] updateAlarms:updatedAlarms ?: alarms completion:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            BOOL success = error == nil;
            [strongSelf hideAlarmActivity:success completion:^{
                if (error) {
                    NSString* title = NSLocalizedString(@"alarm.save-error.title", nil);
                    NSString* message = [error localizedDescription];
                    [[strongSelf delegate] showErrorWithTitle:title message:message from:strongSelf];
                    [[strongSelf service] copyCache:[strongSelf originalAlarm] to:[strongSelf alarm]];
                } else {
                    [SENAnalytics trackAlarmSave:[strongSelf alarm]];
                    [[strongSelf delegate] didSave:YES from:strongSelf];
                }
            }];
        }];
    }];

}

- (void)deleteAlarm {
    [self setDeletingAlarm:YES];
    
    NSString *title = NSLocalizedString(@"alarm.delete.confirm.title", nil);
    NSString *message = NSLocalizedString(@"alarm.delete.confirm.message", nil);
    
    __weak typeof(self) weakSelf = self;
    void(^deleteAlarm)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSMutableArray* alarms = [[[strongSelf service] alarms] mutableCopy];
        [alarms removeObject:[strongSelf alarm]];
        [[strongSelf service] updateAlarms:alarms completion:^(NSError * _Nullable error) {
            BOOL success = error == nil;
            [strongSelf hideAlarmActivity:success completion:^{
                if (success) {
                    [SENAnalytics track:HEMAnalyticsEventDeleteAlarm];
                    [[strongSelf delegate] didSave:YES from:strongSelf];
                } else {
                    NSString* title = NSLocalizedString(@"alarm.delete-error.title", nil);
                    NSString* message = [error localizedDescription];
                    [[strongSelf delegate] showErrorWithTitle:title message:message from:strongSelf];
                }
            }];
        }];
    };
    
    [[self delegate] showConfirmationDialogWithTitle:title message:message action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showAlarmActivity:deleteAlarm];
    } from:self];
}

- (void)toggleSmartness:(UISwitch*)sender {
    BOOL isSmart = [sender isOn];
    if (isSmart != [[self cache] isSmart]) {
        [[self cache] setSmart:isSmart];
        [SENAnalytics track:HEMAnalyticsEventSwitchSmartAlarm
                 properties:@{HEMAnalyticsEventSwitchSmartAlarmOn : @(isSmart)}];
    }
}

- (void)showSmartTutorial:(UIButton*)button {
    [HEMTutorial showTutorialForAlarmSmartnessFrom:[self tutorialPresenter]];
}

#pragma mark - Presenter events

- (void)willAppear {
    [super willAppear];
    HEMClockPickerView* timePicker = (id) [[self tableView] tableHeaderView];
    if (![self configuredClockPicker] && timePicker) {
        [timePicker updateTimeToHour:[[self cache] hour] minute:[[self cache] minute]];
        [self setConfiguredClockPicker:YES];
    }
    
    if ([self reloadExpansionsWhenBack]) {
        [self loadExpansions:nil];
        [self setReloadExpansionsWhenBack:YES];
    }
    
    [[self tableView] reloadData];
}

- (void)didAppear {
    [super didAppear];
    if ([self tutorialPresenter]) {
        [HEMTutorial showTutorialForAlarmsIfNeededFrom:[self tutorialPresenter]];
    }
    [[self tableView] flashScrollIndicators];
}

- (void)didRelayout {
    [super didRelayout];
    
    NSInteger rowCount = [[self rows] count];
    CGFloat rowTotalHeight = rowCount * HEMAlarmConfigCellHeight;
    CGFloat viewPortHeight = CGRectGetHeight([[self tableView] bounds]);
    
    UIView* tableHeaderView = [[self tableView] tableHeaderView];
    CGRect headerFrame = [tableHeaderView frame];
    headerFrame.size.height = MAX(HEMAlarmTimePickerMinHeight, viewPortHeight - rowTotalHeight);
    [tableHeaderView setFrame:headerFrame];
    
    // required to cause it to adjust content size
    [[self tableView] setTableHeaderView:tableHeaderView];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HEMAlarmConfigCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self rows] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* typeNumber = [self rows][[indexPath row]];
    NSString *identifier = nil;
    
    switch ([typeNumber unsignedIntegerValue]) {
        default:
        case HEMAlarmRowTypeSmart:
            identifier = [HEMMainStoryboard alarmSwitchCellReuseIdentifier];
            break;
        case HEMAlarmRowTypeTone:
            identifier = [HEMMainStoryboard alarmSoundCellReuseIdentifier];
            break;
        case HEMAlarmRowTypeRepeat:
            identifier = [HEMMainStoryboard alarmRepeatCellReuseIdentifier];
            break;
        case HEMAlarmRowTypeDelete:
            identifier = [HEMMainStoryboard alarmDeleteCellReuseIdentifier];
            break;
        case HEMAlarmRowTypeThermostat:
        case HEMAlarmRowTypeLight:
            identifier = [HEMMainStoryboard alarmExpansionCellReuseIdentifier];
            break;
    }
    
    return [tableView dequeueReusableCellWithIdentifier:identifier];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMAlarmTableViewCell class]]) {
        HEMAlarmTableViewCell* alarmCell = (id)cell;
        NSNumber* typeNumber = [self rows][[indexPath row]];
        HEMAlarmRowType type = [typeNumber unsignedIntegerValue];
        switch (type) {
            default:
            case HEMAlarmRowTypeTone:
            case HEMAlarmRowTypeRepeat:
            case HEMAlarmRowTypeDelete:
                [self configureAlarmDetailCell:alarmCell forType:type];
                break;
            case HEMAlarmRowTypeSmart:
                [self configureSmartAlarmCell:alarmCell];
                break;
            case HEMAlarmRowTypeThermostat:
            case HEMAlarmRowTypeLight:
                [self configureExpansionCell:alarmCell forType:type];
                break;
        }
    }
}

- (void)configureSmartAlarmCell:(HEMAlarmTableViewCell*)cell {
    [[cell smartSwitch] setOn:[[self cache] isSmart]];
    [[cell smartSwitch] addTarget:self
                           action:@selector(toggleSmartness:)
                 forControlEvents:UIControlEventValueChanged];
    [[cell infoButton] addTarget:self
                          action:@selector(showSmartTutorial:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [[cell titleLabel] setText:NSLocalizedString(@"alarm.smart.title", nil)];
    [[cell titleLabel] setFont:[UIFont body]];
    [[cell titleLabel] setTextColor:[UIColor grey6]];
}

- (void)configureAlarmDetailCell:(HEMAlarmTableViewCell*)cell forType:(HEMAlarmRowType)type {
    NSString *title = nil, *detail = nil;
    UIColor* titleColor = [UIColor grey6];
    
    switch (type) {
        case HEMAlarmRowTypeTone:
            title = NSLocalizedString(@"alarm.sound.title", nil);
            detail = [[self cache] soundName] ?: NSLocalizedString(@"alarm.sound.no-selection", nil);
            break;
        case HEMAlarmRowTypeRepeat:
            title = NSLocalizedString(@"alarm.repeat.title", nil);
            detail = [[self service] localizedTextForRepeatFlags:[[self cache] repeatFlags]];
            break;
        case HEMAlarmRowTypeDelete:
            title = NSLocalizedString(@"alarm.delete.title", nil);
            titleColor = [UIColor red6];
            break;
        default:
            break;
    }
    
    [[cell titleLabel] setText:title];
    [[cell titleLabel] setFont:[UIFont body]];
    [[cell titleLabel] setTextColor:titleColor];
    
    [[cell detailLabel] setText:detail];
    [[cell detailLabel] setFont:[UIFont body]];
    [[cell detailLabel] setTextColor:[UIColor grey4]];
    
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UIView*)customAccessoryViewWithHeight:(CGFloat)height {
    UIImage* accessoryImage = [UIImage imageNamed:@"accessory"];
    CGRect accessoryFrame = CGRectZero;
    accessoryFrame.size.height = height;
    accessoryFrame.size.width = accessoryImage.size.width + HEMAlarmConfigCellLightAccessoryPadding;
    
    UIImageView* accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
    [accessoryView setFrame:accessoryFrame];
    [accessoryView setContentMode:UIViewContentModeCenter];
    
    return accessoryView;
}

- (NSString*)detailValueForExpansion:(SENExpansion*)expansion customTextColor:(UIColor**)customColor {
    NSString* detail = nil;
    
    if ([[self expansionService] isReadyForUse:expansion]) {
        SENAlarmExpansion* alarmExpansion = [[self service] alarmExpansionIn:[self cache] forExpansion:expansion];
        if (![alarmExpansion isEnable]) {
            detail = NSLocalizedString(@"status.off", nil);
        } else if ([expansion type] == SENExpansionTypeLights) {
            NSString* unit = NSLocalizedString(@"measurement.percentage.unit", nil);
            NSString* format = NSLocalizedString(@"alarm.expansion.light.format", nil);
            detail = [NSString stringWithFormat:format, [alarmExpansion targetRange].max, unit];
        } else if ([expansion type] == SENExpansionTypeThermostat) {
            SENExpansionValueRange range = [alarmExpansion targetRange];
            range = [[self expansionService] convertThermostatRangeBasedOnPreference:range];
            if (range.max == range.min) {
                NSString* format = NSLocalizedString(@"alarm.expansion.temp.format", nil);
                detail = [NSString stringWithFormat:format, range.max];
            } else {
                NSString* format = NSLocalizedString(@"alarm.expansion.temp.range.format", nil);
                detail = [NSString stringWithFormat:format, range.min, range.max];
            }
        }
    } else if ([expansion state] == SENExpansionStateNotAvailable) {
        detail = NSLocalizedString(@"expansion.state.not-available", nil);
    }else {
        detail = NSLocalizedString(@"expansion.state.not-connected", nil);
        *customColor = [UIColor tintColor];
    }
    
    return detail;
}

- (void)configureExpansionCell:(HEMAlarmTableViewCell*)expansionCell forType:(HEMAlarmRowType)type {
    NSString *title = nil, *detail = nil;
    UIColor* titleColor = [UIColor grey6], *detailColor = [UIColor grey4];
    BOOL isStillLoading = [self isLoadingExpansions], showError = NO;
    UIView* accessoryView = nil;
    UIImage* icon = nil;
    SENExpansion* expansion = nil;
    SENExpansionType expansionType = SENExpansionTypeUnknown;
    
    switch (type) {
        default:
        case HEMAlarmRowTypeThermostat:
            title = NSLocalizedString(@"alarm.thermostat.title", nil);
            icon = [UIImage imageNamed:@"alarmThermostatIcon"];
            expansionType = SENExpansionTypeThermostat;
            break;
        case HEMAlarmRowTypeLight:
            title = NSLocalizedString(@"alarm.light.title", nil);
            icon = [UIImage imageNamed:@"alarmLightIcon"];
            expansionType = SENExpansionTypeLights;
            break;
    }
    
    if (!isStillLoading) {
        expansion = [[self expansionService] firstExpansionOfType:expansionType
                                                     inExpansions:[self expansions]];
        if (expansion) {
            CGFloat height = CGRectGetHeight([expansionCell bounds]);
            accessoryView = [self customAccessoryViewWithHeight:height];
            detail = [self detailValueForExpansion:expansion customTextColor:&detailColor];
        } else {
            showError = YES;
        }
    }
    
    [expansionCell showActivity:isStillLoading];
    [[expansionCell errorIcon] setHidden:!showError];
    [[expansionCell iconView] setImage:icon];
    
    [[expansionCell titleLabel] setText:title];
    [[expansionCell titleLabel] setFont:[UIFont body]];
    [[expansionCell titleLabel] setTextColor:titleColor];
    
    [[expansionCell detailLabel] setText:detail];
    [[expansionCell detailLabel] setFont:[UIFont body]];
    [[expansionCell detailLabel] setTextColor:detailColor];
    
    [expansionCell setBackgroundColor:[UIColor clearColor]];
    
    UIView* maskView = [expansionCell viewWithTag:HEMAlarmConfigCellExpansionMaskTag];
    if ([expansion state] == SENExpansionStateNotAvailable) {
        if (!maskView) {
            maskView = [[UIView alloc] initWithFrame:[expansionCell bounds]];
            [maskView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:HEMAlarmConfigCellMaskAlpha]];
            [maskView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [maskView setTag:HEMAlarmConfigCellExpansionMaskTag];
        }
        [expansionCell addSubview:maskView];
        [expansionCell setUserInteractionEnabled:NO];
        [expansionCell setAccessoryView:[UIView new]]; // keep the margins from accessory
    } else {
        [maskView removeFromSuperview];
        [expansionCell setUserInteractionEnabled:YES];
        [expansionCell setAccessoryView:accessoryView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HEMAlarmTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString* title = [[cell titleLabel] text];
    NSNumber* typeNumber = [self rows][[indexPath row]];
    HEMAlarmRowType rowType = [typeNumber unsignedIntegerValue];
    
    switch (rowType) {
        case HEMAlarmRowTypeDelete:
            [self deleteAlarm];
            break;
        case HEMAlarmRowTypeThermostat:
        case HEMAlarmRowTypeLight:
            [self handleExpansionSelection:rowType withTitle:title];
            break;
        case HEMAlarmRowTypeTone:
        case HEMAlarmRowTypeRepeat:
            [[self delegate] didSelectRowType:rowType withTitle:title];
            break;
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* typeNumber = [self rows][[indexPath row]];
    switch ([typeNumber unsignedIntegerValue]) {
        case HEMAlarmRowTypeSmart:
            return NO;
        default:
            return YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Expansion Actions

- (void)handleExpansionSelection:(HEMAlarmRowType)rowSelection withTitle:(NSString*)title {
    SENExpansion* expansion;
    switch (rowSelection) {
        default:
        case HEMAlarmRowTypeThermostat:
            expansion =
            [[self expansionService] firstExpansionOfType:SENExpansionTypeThermostat
                                             inExpansions:[self expansions]];
            break;
        case HEMAlarmRowTypeLight:
            expansion =
            [[self expansionService] firstExpansionOfType:SENExpansionTypeLights
                                             inExpansions:[self expansions]];
            break;
    }
    
    if (expansion) {
        if ([[self expansionService] isReadyForUse:expansion]) {
            SENAlarmExpansion* alarmExpansion =
            [[self service] alarmExpansionIn:[self cache] forExpansion:expansion];
            
            HEMAlarmExpansionSetupPresenter* presenter =
            [[HEMAlarmExpansionSetupPresenter alloc] initWithExpansion:expansion
                                                        alarmExpansion:alarmExpansion
                                                      expansionService:[self expansionService]];
            [presenter setDelegate:self];
            
            [[self delegate] showExpansionSetupWithPresenter:presenter
                                                   withTitle:title
                                               fromPresenter:self];
        } else {
            [self setReloadExpansionsWhenBack:YES];
            [[self delegate] showExpansion:expansion fromPresenter:self];
        }
    } else {
        NSString* title = NSLocalizedString(@"alarm.expansion.error.unable.to.load.title", nil);
        NSString* message = NSLocalizedString(@"alarm.expansion.error.unable.to.load.message", nil);
        [[self delegate] showErrorWithTitle:title message:message from:self];
    }
}

#pragma mark - HEMClockPickerViewDelegate

- (void)didUpdateTimeToHour:(NSUInteger)hour minute:(NSUInteger)minute {
    [[self cache] setHour:hour];
    [[self cache] setMinute:minute];
}

#pragma mark - HEMAlarmExpansionSetupDelegate

- (void)updatedAlarmExpansion:(SENAlarmExpansion*)alarmExpansion
   withExpansionConfiguration:(__unused SENExpansionConfig*)config {
    [[self cache] setAlarmExpansion:alarmExpansion];
    [[self tableView] reloadData];
}

#pragma mark - Clean up

- (void)dealloc {
    [_tableView setDataSource:nil];
    [_tableView setDelegate:nil];
    
    HEMClockPickerView* timePicker = (id) [_tableView tableHeaderView];
    [timePicker setDelegate:nil];
}

@end
