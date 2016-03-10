//
//  HEMSleepSoundService.h
//  Sense
//
//  Created by Jimmy Lu on 3/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

@class SENSleepSounds;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMSleepSoundServiceErrorDomain;

typedef void(^HEMSleepSoundsDataHandler)(id _Nullable data, NSError* _Nullable error);
typedef void(^HEMSleepSoundsRequestHandler)(NSError* _Nullable error);

typedef NS_ENUM(NSInteger, HEMSleepSoundServiceError) {
    HEMSleepSoundServiceErrorInProgress = -1,
    HEMSleepSoundServiceErrorTimeout = -2
};

@interface HEMSleepSoundService : SENService

@end

NS_ASSUME_NONNULL_END