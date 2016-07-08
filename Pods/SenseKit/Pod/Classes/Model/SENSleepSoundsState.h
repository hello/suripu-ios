//
//  SENSleepSoundsState.h
//  Pods
//
//  Created by Jimmy Lu on 4/6/16.
//
//

#import <Foundation/Foundation.h>

@class SENSleepSounds;
@class SENSleepSoundStatus;
@class SENSleepSoundDurations;

NS_ASSUME_NONNULL_BEGIN

@interface SENSleepSoundsState : NSObject

@property (nonatomic, strong, readonly) SENSleepSounds* sounds;
@property (nonatomic, strong, readonly) SENSleepSoundDurations* durations;
@property (nonatomic, strong, readonly) SENSleepSoundStatus* status;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END