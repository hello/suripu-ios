//
//  HEMVoiceService.m
//  Sense
//
//  Created by Jimmy Lu on 7/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAPISpeech.h>
#import <SenseKit/SENSpeechResult.h>

#import "HEMVoiceService.h"

NSString* const HEMVoiceNotification = @"HEMVoiceNotificationResult";
NSString* const HEMVoiceNotificationInfoError = @"voice.error";
NSString* const HEMVoiceNotificationInfoResult = @"voice.result";

static CGFloat const HEMVoiceServiceWaitDelay = 1.0f;

typedef void(^HEMVoiceCommandsHandler)(NSArray<SENSpeechResult*>* _Nullable results,
                                       NSError* _Nullable error);

@interface HEMVoiceService()

@property (nonatomic, assign, getter=isStarted) BOOL started;
@property (nonatomic, strong) NSDate* lastVoiceResultDate;

@end

@implementation HEMVoiceService

- (void)mostRecentVoiceCommands:(HEMVoiceCommandsHandler)completion {
    [SENAPISpeech getRecentVoiceCommands:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion(data, error);
    }];
}

- (void)startListeningForVoiceResult {
    if (![self isStarted]) {
        [self setStarted:YES];
        [self waitForVoiceCommandResult];
    }
}

- (void)waitForVoiceCommandResult {
    __weak typeof(self) weakSelf = self;
    [self mostRecentVoiceCommands:^(NSArray<SENSpeechResult *> * results, NSError * error) {
        __strong typeof(weakSelf) strongself = weakSelf;
        NSDictionary* info = nil;
        
        if (error) {
            info = @{HEMVoiceNotificationInfoError : error};
        } else if ([results count] > 0) {
            SENSpeechResult* result = [results lastObject];
            NSDate* resultDate = [result date];
            if (![self lastVoiceResultDate]
                || [[self lastVoiceResultDate] compare:resultDate] == NSOrderedAscending) {
                [self setLastVoiceResultDate:resultDate];
                info = @{HEMVoiceNotificationInfoResult : [results lastObject]};
            }
        }
        
        if (info) {
            NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:HEMVoiceNotification
                                  object:strongself
                                userInfo:info];
        }
        
        int64_t delay = (int64_t)(HEMVoiceServiceWaitDelay * NSEC_PER_SEC);
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delay);
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            if ([strongself isStarted]) {
                [strongself waitForVoiceCommandResult];
            }
        });
        
    }];
}

- (void)stopListeningForVoiceResult {
    [self setStarted:NO];
}

@end
