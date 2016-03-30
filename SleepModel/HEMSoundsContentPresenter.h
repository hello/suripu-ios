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
@class HEMSoundsContentPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMSoundContentDelegate <NSObject>

- (void)loadAlarmsFrom:(HEMSoundsContentPresenter*)presenter;
- (void)loadSleepSounds:(SENSleepSounds*)sleepSounds from:(HEMSoundsContentPresenter*)presenter;
- (void)pairWithSenseFrom:(HEMSoundsContentPresenter*)presenter;
- (void)unloadContentControllersFrom:(HEMSoundsContentPresenter*)presenter;

@end

@interface HEMSoundsContentPresenter : HEMPresenter

@property (nonatomic, weak, nullable) id<HEMSoundContentDelegate> delegate;

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService*)sleepSoundService
                             alarmService:(HEMAlarmService*)alarmService
                            deviceService:(HEMDeviceService*)deviceService;

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator;
- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNavigationView
             withHeightConstraint:(NSLayoutConstraint*)heightConstraint;
- (void)bindWithErrorCollectionView:(UICollectionView*)collectionView;
- (void)reload;

@end

NS_ASSUME_NONNULL_END