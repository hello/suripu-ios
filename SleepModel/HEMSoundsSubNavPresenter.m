//
//  HEMSoundSwitchPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSleepSounds.h>

#import "HEMStyle.h"
#import "HEMSoundsSubNavPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSubNavigationView.h"
#import "HEMSleepSoundService.h"
#import "HEMDeviceService.h"
#import "HEMAlarmService.h"

typedef NS_ENUM(NSUInteger, HEMSoundsSubNavOption) {
    HEMSoundsSubNavOptionAlarms = 1,
    HEMSoundsSubNavOptionSleepSounds
};

@interface HEMSoundsSubNavPresenter()

@property (nonatomic, weak) HEMSleepSoundService* sleepSoundService;
@property (nonatomic, weak) HEMAlarmService* alarmService;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, weak) HEMSubNavigationView* subNav;
@property (nonatomic, assign) CGFloat origSubNavHeight;
@property (nonatomic, weak) NSLayoutConstraint* subNavHeightConstraint;
@property (nonatomic, strong) SENSleepSounds* availableSleepSounds;

@end

@implementation HEMSoundsSubNavPresenter

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService*)sleepSoundService
                             alarmService:(HEMAlarmService*)alarmService
                            deviceService:(HEMDeviceService*)deviceService {
    self = [super init];
    if (self) {
        _sleepSoundService = sleepSoundService;
        _alarmService = alarmService;
        _deviceService = deviceService;
    }
    return self;
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator {
    [activityIndicator setHidden:NO];
    [activityIndicator start];
    [self setActivityIndicator:activityIndicator];
}

- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNavigationView
             withHeightConstraint:(NSLayoutConstraint*)heightConstraint {
    [subNavigationView setSelectedControlTag:HEMSoundsSubNavOptionAlarms];
    // hide the sub nav until determined that we need it
    [self setOrigSubNavHeight:[heightConstraint constant]];
    [heightConstraint setConstant:0.0f];
    
    [self setSubNav:subNavigationView];
    [self setSubNavHeightConstraint:heightConstraint];
    [self loadData];
}

- (NSString*)localizedTitleFor:(HEMSoundsSubNavOption)option {
    switch (option) {
        default:
        case HEMSoundsSubNavOptionAlarms:
            return [NSLocalizedString(@"alarms.title", nil) uppercaseString];
        case HEMSoundsSubNavOptionSleepSounds:
            return [NSLocalizedString(@"sleep-sounds.title", nil) uppercaseString];
    }
}

- (UIButton*)soundButtonFor:(HEMSoundsSubNavOption)option {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitle:[self localizedTitleFor:option] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont subNavTitleTextFont]];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor subNavInactiveTitleColor] forState:UIControlStateNormal];
    [button setSelected:option == [[self subNav] selectedControlTag]];
    [button setTag:option];
    [button addTarget:self action:@selector(changeOption:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)stopActivityAndLoad {
    [[self activityIndicator] stop];
    [[self activityIndicator] setHidden:YES];
    
    BOOL hasSense = [[[self deviceService] devices] hasPairedSense];
    
    if (![[self subNav] hasControls]) {
        if ([self availableSleepSounds]) {
            [[self subNavHeightConstraint] setConstant:[self origSubNavHeight]];
            
            [[self subNav] addControl:[self soundButtonFor:HEMSoundsSubNavOptionAlarms]];
            [[self subNav] addControl:[self soundButtonFor:HEMSoundsSubNavOptionSleepSounds]];
            
            [[self subNav] setNeedsDisplay];
        }
        [[self delegate] loadAlarms:hasSense];
    } else if ([[self subNav] selectedControlTag] == HEMSoundsSubNavOptionAlarms) {
        [[self delegate] loadAlarms:hasSense];
    } else if ([[self subNav] selectedControlTag] == HEMSoundsSubNavOptionSleepSounds) {
        [[self delegate] loadSleepSounds:[self availableSleepSounds]];
    }
}

- (void)loadData {
    __weak typeof(self) weakSelf = self;
    
    [self checkDeviceRequirement:^(BOOL meetsRequirements) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!meetsRequirements) {
            [strongSelf stopActivityAndLoad];
        } else {
            dispatch_group_t dataGroup = dispatch_group_create();
            
            dispatch_group_enter(dataGroup);
            [[strongSelf sleepSoundService] availableSleepSounds:^(id _Nullable data, NSError * _Nullable error) {
                if ([data isKindOfClass:[SENSleepSounds class]]) {
                    [strongSelf setAvailableSleepSounds:data];
                }
                dispatch_group_leave(dataGroup);
            }];
            
            dispatch_group_enter(dataGroup);
            [[strongSelf alarmService] refreshAlarms:^(NSArray<SENAlarm *> * _Nullable alarms, NSError * _Nullable error) {
                dispatch_group_leave(dataGroup);
            }];
            
            dispatch_group_notify(dataGroup, dispatch_get_main_queue(), ^{
                [strongSelf stopActivityAndLoad];
            });
        }
    }];
}

- (void)checkDeviceRequirement:(void(^)(BOOL meetsRequirements))completion {
    [[self deviceService] refreshMetadata:^(SENPairedDevices * _Nullable devices, NSError * _Nullable error) {
        completion ([devices hasPairedSense]);
    }];
}

#pragma mark - Actions

- (void)changeOption:(UIButton*)optionButton {
    
    switch ([optionButton tag]) {
        case HEMSoundsSubNavOptionAlarms:
            [[self delegate] loadAlarms:[[[self deviceService] devices] hasPairedSense]];
            break;
        case HEMSoundsSubNavOptionSleepSounds:
        default:
            [[self delegate] loadSleepSounds:[self availableSleepSounds]];
            break;
    }
}

@end
