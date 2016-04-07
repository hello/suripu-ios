//
//  SENAPISleepSounds.h
//  Pods
//
//  Created by Jimmy Lu on 3/8/16.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENSleepSoundRequest;

NS_ASSUME_NONNULL_BEGIN

@interface SENAPISleepSounds : NSObject

+ (void)availableSleepSounds:(SENAPIDataBlock)completion;
+ (void)availableDurations:(SENAPIDataBlock)completion;
+ (void)executeRequest:(SENSleepSoundRequest*)request
            completion:(SENAPIErrorBlock)completion;
+ (void)checkRequestStatus:(SENAPIDataBlock)completion;
+ (void)sleepSoundsState:(SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END