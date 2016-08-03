//
//  HEMAlarmPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSound.h>

#import "HEMAlarmPresenter.h"
#import "HEMAlarmService.h"
#import "HEMStyle.h"
#import "HEMAlarmCache.h"
#import "HEMTutorial.h"
#import "HEMClockPickerView.h"
#import "HEMMainStoryboard.h"
#import "HEMAlarmTableViewCell.h"
#import "HEMActivityCoverView.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const HEMAlarmPresenterSuccessDelay = 0.8f;

typedef NS_ENUM(NSUInteger, HEMAlarmTableRow) {
    HEMAlarmTableRowSmart = 0,
    HEMAlarmTableRowSound,
    HEMAlarmTableRowRepeat,
    HEMAlarmTableRowDeletion
};

@interface HEMAlarmPresenter() <
    UITableViewDataSource,
    UITableViewDelegate,
    HEMClockPickerViewDelegate
>

@property (nonatomic, weak) HEMAlarmService* service;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) UIViewController* tutorialPresenter;
@property (nonatomic, weak) HEMClockPickerView* clockPicker;
@property (nonatomic, strong) HEMAlarmCache* cache;
@property (nonatomic, strong) HEMAlarmCache* originalAlarm;
@property (nonatomic, weak) SENAlarm* alarm;
@property (nonatomic, assign) BOOL configuredClockPicker;
@property (nonatomic, assign) BOOL deletingAlarm;
@property (nonatomic, strong) HEMActivityCoverView* activityView;

@end

@implementation HEMAlarmPresenter

- (instancetype)initWithAlarm:(SENAlarm*)alarm alarmService:(HEMAlarmService*)alarmService {
    self = [super init];
    if (self) {
        _alarm = alarm;
        _service = alarmService;
        _cache = [HEMAlarmCache new];
        _originalAlarm = [HEMAlarmCache new];
        
        if (_alarm) {
            [_cache cacheValuesFromAlarm:_alarm];
            [_originalAlarm cacheValuesFromAlarm:_alarm];
        }
        
        if (![_service hasLoadedAlarms]) {
            [_service refreshAlarms:nil];
        }
        
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView heightConstraint:(NSLayoutConstraint*)heightConstraint {
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    
    if (![[self alarm] isSaved]) {
        // remove the height allocated for the delete button
        CGFloat currentConstant = [heightConstraint constant];
        CGFloat rowHeight = [tableView rowHeight];
        [heightConstraint setConstant:currentConstant - rowHeight];
    }
    
    [self setTableView:tableView];
    [self reloadWithAlarmSoundMetadata];
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

- (void)bindWithClockPickerView:(HEMClockPickerView*)clockPicker {
    [clockPicker setDelegate:self];
    [clockPicker setBackgroundColor:[UIColor lightBackgroundColor]];
    [self setClockPicker:clockPicker];
}

- (void)bindWithTutorialPresentingController:(UIViewController*)controller {
    [self setTutorialPresenter:controller];
}

- (void)bindWithButtonContainer:(UIView*)container
                   cancelButton:(UIButton*)cancelButton
                     saveButton:(UIButton*)saveButton {
    [container addSubview:[self artificialBorderInView:container]];
    
    [[saveButton titleLabel] setFont:[UIFont alarmButtonFont]];
    [saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    
    [[cancelButton titleLabel] setFont:[UIFont alarmButtonFont]];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)cancel:(UIButton*)button {
    [[self delegate] didSave:NO from:self];
}

- (void)save:(UIButton*)button {
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
    [[self cache] setSmart:isSmart];
    [SENAnalytics track:HEMAnalyticsEventSwitchSmartAlarm
             properties:@{HEMAnalyticsEventSwitchSmartAlarmOn : @(isSmart)}];
}

- (void)showSmartTutorial:(UIButton*)button {
    [HEMTutorial showTutorialForAlarmSmartnessFrom:[self tutorialPresenter]];
}

- (UIView*)artificialBorderInView:(UIView*)view {
    CGFloat width = CGRectGetWidth([view bounds]);
    CGRect borderFrame = CGRectZero;
    borderFrame.size.width = width;
    borderFrame.size.height = HEMStyleButtonContainerBorderWidth;
    UIView* border = [[UIView alloc] initWithFrame:borderFrame];
    [border setBackgroundColor:[UIColor separatorColor]];
    return border;
}

#pragma mark - Presenter events

- (void)willAppear {
    [super willAppear];
    if (![self configuredClockPicker] && [self clockPicker]) {
        [[self clockPicker] updateTimeToHour:[[self cache] hour] minute:[[self cache] minute]];
        [self setConfiguredClockPicker:YES];
    }
    [[self tableView] reloadData];
}

- (void)didAppear {
    [super didAppear];
    if ([self tutorialPresenter]) {
        [HEMTutorial showTutorialForAlarmsIfNeededFrom:[self tutorialPresenter]];
    }
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    UIImage* shadow = [UIImage imageNamed:@"topShadowStraight"];
    return [shadow size].height;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIImage* shadow = [UIImage imageNamed:@"topShadowStraight"];
    UIImageView* shadowView = [[UIImageView alloc] initWithImage:shadow];
    [shadowView setBackgroundColor:[UIColor clearColor]]; // let it blend with clock view
    [shadowView setContentMode:UIViewContentModeScaleAspectFill];
    [shadowView addSubview:[self artificialBorderInView:shadowView]];
    return shadowView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ![[self alarm] isSaved] ? 3 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier, *title = nil, *detail = nil;
    BOOL switchState = NO;
    switch ([indexPath row]) {
        default:
        case HEMAlarmTableRowSmart:
            identifier = [HEMMainStoryboard alarmSwitchCellReuseIdentifier];
            switchState = [[self cache] isSmart];
            title = NSLocalizedString(@"alarm.smart.title", nil);
            break;
        case HEMAlarmTableRowSound:
            identifier = [HEMMainStoryboard alarmSoundCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.sound.title", nil);
            detail = [[self cache] soundName] ?: NSLocalizedString(@"alarm.sound.no-selection", nil);
            break;
        case HEMAlarmTableRowRepeat:
            identifier = [HEMMainStoryboard alarmRepeatCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.repeat.title", nil);
            detail = [[self service] localizedTextForRepeatFlags:[[self cache] repeatFlags]];
            break;
        case HEMAlarmTableRowDeletion:
            identifier = [HEMMainStoryboard alarmDeleteCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.delete.title", nil);
            break;
    }
    HEMAlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [[cell titleLabel] setText:title];
    [[cell titleLabel] setFont:[UIFont alarmTitleFont]];
    [[cell detailLabel] setText:detail];
    [[cell detailLabel] setFont:[UIFont alarmDetailFont]];
    [cell setBackgroundColor:[UIColor clearColor]];
    // only cells prototyped with these views will have the following effect.
    // other cells will be No-Op
    [[cell smartSwitch] setOn:switchState];
    [[cell smartSwitch] addTarget:self
                           action:@selector(toggleSmartness:)
                 forControlEvents:UIControlEventTouchUpInside];
    [[cell infoButton] addTarget:self
                          action:@selector(showSmartTutorial:)
                forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch ([indexPath row]) {
        case HEMAlarmTableRowDeletion:
            [self deleteAlarm];
            break;
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return [indexPath row] != HEMAlarmTableRowSmart;
}

#pragma mark - HEMClockPickerViewDelegate

- (void)didUpdateTimeToHour:(NSUInteger)hour minute:(NSUInteger)minute {
    [[self cache] setHour:hour];
    [[self cache] setMinute:minute];
}

#pragma mark - Clean up

- (void)dealloc {
    [_tableView setDataSource:nil];
    [_tableView setDelegate:nil];
    [_clockPicker setDelegate:nil];
}

@end
