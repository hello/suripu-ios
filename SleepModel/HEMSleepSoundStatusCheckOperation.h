//
//  HEMSleepSoundStatusCheckOperation.h
//  Sense
//
//  Created by Jimmy Lu on 4/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENSleepSoundStatus;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMSleepSoundStatusOpCallback)(SENSleepSoundStatus* _Nullable status);

@interface HEMSleepSoundStatusCheckOperation : NSOperation

@property (nonatomic, strong) HEMSleepSoundStatusOpCallback resultCompletionBlock;

@end

NS_ASSUME_NONNULL_END