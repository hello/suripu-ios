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

@end

@implementation HEMAlarmPresenter

- (instancetype)initWithAlarm:(SENAlarm*)alarm alarmService:(HEMAlarmService*)alarmService {
    self = [super init];
    if (self) {
        _alarm = alarm;
        _service = alarmService;
        _cache = [HEMAlarmCache new];
        _originalAlarm = [HEMAlarmCache new];
        
        if (alarm) {
            [_cache cacheValuesFromAlarm:alarm];
            [_originalAlarm cacheValuesFromAlarm:alarm];
        }
        
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView heightConstraint:(NSLayoutConstraint*)heightConstraint {
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    NSShadow* shadow = [NSShadow shadowForAlarmView];
    
    CALayer *layer = [tableView layer];
    [layer setShadowRadius:[shadow shadowBlurRadius]];
    [layer setShadowOffset:[shadow shadowOffset]];
    [layer setShadowOpacity:0.05f];
    
    if (![[self alarm] isSaved]) {
        CGFloat currentConstant = [heightConstraint constant];
        [heightConstraint setConstant:currentConstant - [tableView rowHeight]];
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
    [self setClockPicker:clockPicker];
}

- (void)bindWithTutorialPresentingController:(UIViewController*)controller {
    [self setTutorialPresenter:controller];
}

- (void)bindWithSaveButton:(UIButton*)saveButton {
    [[saveButton titleLabel] setFont:[UIFont alarmButtonFont]];
    [saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithCancelButton:(UIButton*)cancelButton {
    [[cancelButton titleLabel] setFont:[UIFont alarmButtonFont]];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions

- (void)cancel:(UIButton*)button {
    [[self delegate] dismissWithMessage:nil saved:NO from:self];
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
    
    [[self cache] setOn:YES];
    [[self service] copyCache:[self cache] to:[self alarm]];
    
    __weak typeof(self) weakSelf = self;
    [[self service] updateAlarms:[SENAlarm savedAlarms] completion:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            NSString* title = NSLocalizedString(@"alarm.save-error.title", nil);
            NSString* message = [error localizedDescription];
            [[weakSelf delegate] showErrorWithTitle:title message:message from:weakSelf];
            
            if ([[strongSelf alarm] isSaved]) {
                [[strongSelf alarm] delete];
            } else {
                [[strongSelf service] copyCache:[strongSelf originalAlarm] to:[strongSelf alarm]];
            }
        } else {
            [SENAnalytics trackAlarmSave:[strongSelf alarm]];
            NSString* message = NSLocalizedString(@"actions.saved", nil);
            [[strongSelf delegate] dismissWithMessage:message saved:YES from:strongSelf];
        }
    }];
}

- (void)deleteAlarm {
    NSString *title = NSLocalizedString(@"alarm.delete.confirm.title", nil);
    NSString *message = NSLocalizedString(@"alarm.delete.confirm.message", nil);
    
    __weak typeof(self) weakSelf = self;
    [[self delegate] showConfirmationDialogWithTitle:title message:message action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf alarm] delete]; // removes from local storage, not actual data
        [[strongSelf service] updateAlarms:[SENAlarm savedAlarms] completion:^(NSError * _Nullable error) {
            if (error) {
                [[strongSelf alarm] save];
            } else {
                [SENAnalytics track:HEMAnalyticsEventDeleteAlarm];
                [[strongSelf delegate] dismissWithMessage:nil saved:NO from:strongSelf];
            }
        }];
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
    [[cell detailLabel] setText:detail];
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
