//
//  SENSleepSoundStatus.h
//  Pods
//
//  Created by Jimmy Lu on 3/9/16.
//
//

#import <Foundation/Foundation.h>

@class SENSleepSound;
@class SENSleepSoundDuration;

NS_ASSUME_NONNULL_BEGIN

@interface SENSleepSoundStatus : NSObject

@property (nonatomic, assign, getter=isPlaying, readonly) BOOL playing;
@property (nonatomic, strong, readonly, nullable) SENSleepSound* sound;
@property (nonatomic, strong, readonly, nullable) SENSleepSoundDuration* duration;
@property (nonatomic, strong, readonly, nullable) NSNumber* volume;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END