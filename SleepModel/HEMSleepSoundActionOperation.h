//
//  HEMSleepSoundActionOperation.h
//  Sense
//
//  Created by Jimmy Lu on 4/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenseKit/SENSleepSoundRequest.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMSleepSoundActionErrorDomain;

typedef NS_ENUM(NSInteger, HEMSleepSoundActionError) {
    HEMSleepSoundActionErrorStatusTimeout = -1
};

typedef void(^HEMSleepSoundActionCallback)(BOOL cancelled, NSError* _Nullable error);

@interface HEMSleepSoundActionOperation : NSOperation

@property (nonatomic, copy) HEMSleepSoundActionCallback resultCompletionBlock;

- (instancetype)initWithAction:(SENSleepSoundRequest*)action;

@end

NS_ASSUME_NONNULL_END