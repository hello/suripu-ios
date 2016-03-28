//
//  HEMSleepSoundService.h
//  Sense
//
//  Created by Jimmy Lu on 3/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

@class SENSleepSounds;
@class SENSleepSound;
@class SENSleepSoundDurations;
@class SENSleepSoundDuration;
@class HEMSleepSoundVolume;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMSleepSoundServiceErrorDomain;
extern CGFloat const HEMSleepSoundServiceVolumeHigh;
extern CGFloat const HEMSleepSoundServiceVolumeMedium;
extern CGFloat const HEMSleepSoundServiceVolumeLow;

typedef void(^HEMSleepSoundsDataHandler)(id _Nullable data, NSError* _Nullable error);
typedef void(^HEMSleepSoundsRequestHandler)(NSError* _Nullable error);

typedef NS_ENUM(NSInteger, HEMSleepSoundServiceError) {
    HEMSleepSoundServiceErrorInProgress = -1,
    HEMSleepSoundServiceErrorTimeout = -2
};

@interface HEMSleepSoundService : SENService

- (NSArray<HEMSleepSoundVolume*>*)availableVolumeOptions;
- (void)availableSleepSounds:(HEMSleepSoundsDataHandler)completion;
- (void)availableDurations:(HEMSleepSoundsDataHandler)completion;
- (SENSleepSound*)defaultSleepSoundFrom:(SENSleepSounds*)available;
- (SENSleepSoundDuration*)defaultDurationFrom:(SENSleepSoundDurations*)available;
- (HEMSleepSoundVolume*)defaultVolume;
- (void)playSound:(SENSleepSound*)sound
      forDuration:(SENSleepSoundDuration*)duration
       withVolume:(NSInteger)volume
       completion:(HEMSleepSoundsRequestHandler)completion;
- (void)stopPlaying:(HEMSleepSoundsRequestHandler)completion;

@end

NS_ASSUME_NONNULL_END