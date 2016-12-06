//
//  HEMSleepSoundPlayerPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 3/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMSleepSoundPlayerPresenter;
@class HEMSleepSoundService;
@class SENSleepSound;
@class SENSleepSounds;
@class SENSleepSoundDuration;
@class SENSleepSoundDurations;
@class HEMSleepSoundVolume;
@class HEMDeviceService;
@class HEMActivityIndicatorView;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMSleepSoundPlayerDelegate <NSObject>

- (void)presentErrorWithTitle:(NSString*)title message:(NSString*)message;
- (void)showAvailableSounds:(NSArray *)sounds
          selectedSoundName:(NSString*)selectedName
                  withTitle:(NSString*)title
                   subTitle:(NSString*)subTitle
                       from:(HEMSleepSoundPlayerPresenter *)presenter;
- (void)showAvailableDurations:(NSArray *)durations
          selectedDurationName:(NSString*)selectedName
                     withTitle:(NSString*)title
                      subTitle:(NSString*)subTitle
                          from:(HEMSleepSoundPlayerPresenter *)presenter;
- (void)showVolumeOptions:(NSArray *)volumeOptions
       selectedVolumeName:(NSString*)selectedName
                withTitle:(NSString*)title
                 subTitle:(NSString*)subTitle
                     from:(HEMSleepSoundPlayerPresenter *)presenter;

@end

@interface HEMSleepSoundPlayerPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMSleepSoundPlayerDelegate> delegate;

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService *)service
                            deviceService:(nullable HEMDeviceService*)deviceService;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithActionButton:(UIButton*)button
            bottomConstraint:(NSLayoutConstraint*)bottomConstraint;
- (void)bindWithBackgroundView:(UIView*)backgroundView;
- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicator;
- (void)setSelectedSound:(SENSleepSound*)sound save:(BOOL)save;
- (void)setSelectedDuration:(SENSleepSoundDuration*)duration save:(BOOL)save;
- (void)setSelectedVolume:(HEMSleepSoundVolume *)selectedVolume save:(BOOL)save;

@end

NS_ASSUME_NONNULL_END
