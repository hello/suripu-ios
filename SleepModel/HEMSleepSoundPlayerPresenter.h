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

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService*)service
                           andSleepSounds:(nullable SENSleepSounds*)sleepSounds;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithActionButton:(UIButton*)button;
- (void)setSelectedSound:(SENSleepSound*)sound;
- (void)setSelectedDuration:(SENSleepSoundDuration*)duration;
- (void)setSelectedVolume:(HEMSleepSoundVolume *)selectedVolume;

@end

NS_ASSUME_NONNULL_END