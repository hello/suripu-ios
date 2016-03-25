//
//  HEMSoundSwitchPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 3/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMSleepSoundService;
@class HEMAlarmService;
@class HEMDeviceService;
@class HEMActivityIndicatorView;
@class HEMSubNavigationView;
@class SENSleepSounds;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMSoundSubNavDelegate <NSObject>

- (void)loadAlarms:(BOOL)hasSensePaired;
- (void)loadSleepSounds:(SENSleepSounds*)sleepSounds;

@end

@interface HEMSoundsSubNavPresenter : HEMPresenter

@property (nonatomic, weak, nullable) id<HEMSoundSubNavDelegate> delegate;

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService*)sleepSoundService
                             alarmService:(HEMAlarmService*)alarmService
                            deviceService:(HEMDeviceService*)deviceService;

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator;
- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNavigationView
             withHeightConstraint:(NSLayoutConstraint*)heightConstraint;

@end

NS_ASSUME_NONNULL_END