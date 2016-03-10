//
//  HEMSleepSoundService.m
//  Sense
//
//  Created by Jimmy Lu on 3/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAPISleepSounds.h>
#import <SenseKit/SENSleepSoundRequest.h>
#import <SenseKit/SENSleepSoundDurations.h>
#import <SenseKit/SENSleepSoundStatus.h>
#import <SenseKit/SENSleepSounds.h>

#import "HEMSleepSoundService.h"

NSString* const HEMSleepSoundServiceErrorDomain = @"is.hello.sense.sleep-sound";

static CGFloat const HEMSleepSoundServiceRequestTimeoutInSecs = 30.0f;
static CGFloat const HEMSleepSoundServiceRequestIntervalInSecs = 2.0f;

@interface HEMSleepSoundService()

@property (nonatomic, strong) NSTimer* timeout;
@property (nonatomic, strong) SENSleepSoundRequest* currentRequest;
@property (nonatomic, copy) HEMSleepSoundsRequestHandler currentRequestCallback;

@end

@implementation HEMSleepSoundService

- (void)availableSleepSounds:(HEMSleepSoundsDataHandler)completion {
    [SENAPISleepSounds availableSleepSounds:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (void)availableDurations:(HEMSleepSoundsDataHandler)completion {
    [SENAPISleepSounds availableDurations:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (SENSleepSound*)defaultSleepSoundFrom:(SENSleepSounds*)available {
    return [[available sounds] firstObject];
}

- (SENSleepSoundDuration*)defaultDurationFrom:(SENSleepSoundDurations*)available {
    return [[available durations] firstObject];
}

- (NSError*)errorWithCode:(HEMSleepSoundServiceError)code {
    return [NSError errorWithDomain:HEMSleepSoundServiceErrorDomain
                               code:code
                           userInfo:nil];
}

- (void)fireRequest:(SENSleepSoundRequest*)request
         completion:(HEMSleepSoundsRequestHandler)completion {
    [self setCurrentRequest:request];
    
    __weak typeof(self) weakSelf = self;
    [SENAPISleepSounds executeRequest:request completion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
            completion (error);
        } else {
            [strongSelf setCurrentRequestCallback:completion];
            [strongSelf scheduleRequestStatusTimer];
            [strongSelf checkStatusForCurrentRequest];
        }
    }];
    
}

- (void)playSound:(SENSleepSound*)sound
      forDuration:(SENSleepSoundDuration*)duration
       withVolume:(NSInteger)volume
       completion:(HEMSleepSoundsRequestHandler)completion {
    
    if ([self currentRequest]) {
        completion ([self errorWithCode:HEMSleepSoundServiceErrorInProgress]);
        return;
    }
    
    NSNumber* volumeValue = @(MIN(MAX(0, volume), 100));
    SENSleepSoundRequestPlay* request = [[SENSleepSoundRequestPlay alloc] initWithSoundId:[sound identifier]
                                                                               durationId:[duration identifier]
                                                                                   volume:volumeValue];
    
    [self fireRequest:request completion:completion];
}

- (void)stopPlaying:(HEMSleepSoundsRequestHandler)completion {
    if ([self currentRequest]) {
        completion ([self errorWithCode:HEMSleepSoundServiceErrorInProgress]);
        return;
    }
    
    [self fireRequest:[SENSleepSoundRequestStop new] completion:completion];
}

- (BOOL)isRequest:(SENSleepSoundRequest*)request successful:(SENSleepSoundStatus*)status {
    return ([request isKindOfClass:[SENSleepSoundRequestPlay class]] && [status isPlaying])
        || ([request isKindOfClass:[SENSleepSoundRequestStop class]] && ![status isPlaying]);
}

- (void)checkStatusForCurrentRequest {
    __weak typeof(self) weakSelf = self;
    CGFloat secs = HEMSleepSoundServiceRequestIntervalInSecs;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, secs*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [SENAPISleepSounds checkRequestStatus:^(id data, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                [SENAnalytics trackError:error];
                // if there is an error, check again.  might not have one again?
            } else if ([strongSelf isRequest:[strongSelf currentRequest] successful:data]) {
                [strongSelf respondToCurrentRequest:nil];
            } else {
                [strongSelf checkStatusForCurrentRequest];
            }
        }];
    });
}

- (void)respondToCurrentRequest:(NSError*)error {
    if ([self currentRequestCallback]) {
        [self currentRequestCallback] (error);
        [self setCurrentRequestCallback:nil];
        [self setCurrentRequest:nil];
    }
}

#pragma mark - Timeouts

- (void)scheduleRequestStatusTimer {
    NSTimer* timeout = [NSTimer scheduledTimerWithTimeInterval:HEMSleepSoundServiceRequestTimeoutInSecs
                                                        target:self
                                                      selector:@selector(requestTimeout)
                                                      userInfo:nil
                                                       repeats:NO];
    [self setTimeout:timeout];
}

- (void)requestTimeout {
    [self setTimeout:nil];
    [self respondToCurrentRequest:[self errorWithCode:HEMSleepSoundServiceErrorTimeout]];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_timeout) {
        [_timeout invalidate];
    }
}


@end
