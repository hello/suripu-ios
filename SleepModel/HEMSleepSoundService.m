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
#import <SenseKit/SENSleepSoundsState.h>

#import "HEMSleepSoundService.h"
#import "HEMSleepSoundVolume.h"
#import "HEMSleepSoundActionOperation.h"

NSString* const HEMSleepSoundServiceErrorDomain = @"is.hello.sense.sleep-sound";

static CGFloat const HEMSleepSoundServiceVolumeHigh = 80.0f;
static CGFloat const HEMSleepSoundServiceVolumeMedium = 50.0f;
static CGFloat const HEMSleepSoundServiceVolumeLow = 25.0f;
static CGFloat const HEMSleepSoundServiceSenseLastSeeenThreshold = 1800.0f; // 30 minutes

@interface HEMSleepSoundService()

@property (nonatomic, strong) NSOperationQueue* apiQueue;
@property (nonatomic, strong) NSArray<HEMSleepSoundVolume*>* availableVolumeOptions;

@end

@implementation HEMSleepSoundService

- (instancetype)init {
    self = [super init];
    if (self) {
        _apiQueue = [NSOperationQueue new];
        [_apiQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (NSArray<HEMSleepSoundVolume*>*)availableVolumeOptions {
    if (!_availableVolumeOptions) {
        NSString* high = NSLocalizedString(@"sleep-sounds.volume.high", nil);
        NSString* med = NSLocalizedString(@"sleep-sounds.volume.medium", nil);
        NSString* low = NSLocalizedString(@"sleep-sounds.volume.low", nil);
        _availableVolumeOptions = @[[[HEMSleepSoundVolume alloc] initWithName:low volume:HEMSleepSoundServiceVolumeLow],
                                    [[HEMSleepSoundVolume alloc] initWithName:med volume:HEMSleepSoundServiceVolumeMedium],
                                    [[HEMSleepSoundVolume alloc] initWithName:high volume:HEMSleepSoundServiceVolumeHigh]];
    }
    return _availableVolumeOptions;
}

- (HEMSleepSoundVolume*)volumeObjectForValue:(NSNumber*)value {
    NSArray<HEMSleepSoundVolume*>* volumes = [self availableVolumeOptions];
    HEMSleepSoundVolume* object = [self defaultVolume];
    for (HEMSleepSoundVolume* volume in volumes) {
        if ([volume volume] == [value CGFloatValue]) {
            object = volume;
            break;
        }
    }
    return object;
}

- (void)currentSleepSoundsState:(HEMSleepSoundsDataHandler)completion {
    [SENAPISleepSounds sleepSoundsState:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

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

- (HEMSleepSoundVolume*)defaultVolume {
    if ([[self availableVolumeOptions] count] == 3) {
        return [self availableVolumeOptions][1]; // take the middle
    } else {
        return [[self availableVolumeOptions] firstObject];
    }
}

- (NSError*)errorWithCode:(HEMSleepSoundServiceError)code {
    return [NSError errorWithDomain:HEMSleepSoundServiceErrorDomain
                               code:code
                           userInfo:nil];
}

- (NSError*)translateOperationError:(NSError*)error {
    NSError* localError = error;
    if (error) {
        if ([[error domain] isEqualToString:HEMSleepSoundActionErrorDomain]) {
            switch ([error code]) {
                case HEMSleepSoundActionErrorStatusTimeout:
                    localError = [NSError errorWithDomain:HEMSleepSoundServiceErrorDomain
                                                     code:HEMSleepSoundServiceErrorTimeout
                                                 userInfo:nil];
                    break;
                default:
                    break;
            }
        }
    }
    return localError;
}

- (HEMSleepSoundActionOperation*)operationForRequest:(SENSleepSoundRequest*)request
                                          completion:(HEMSleepSoundsRequestHandler)completion {
    
    HEMSleepSoundActionOperation* actionOperation
        = [[HEMSleepSoundActionOperation alloc] initWithAction:request];
    
    __weak typeof(self) weakSelf = self;
    [actionOperation setResultCompletionBlock:^(BOOL cancelled, NSError* _Nullable error) {
        if (!cancelled) {
            completion ([weakSelf translateOperationError:error]);
        }
    }];
    return actionOperation;
}

- (void)playSound:(SENSleepSound*)sound
      forDuration:(SENSleepSoundDuration*)duration
       withVolume:(NSInteger)volume
       completion:(HEMSleepSoundsRequestHandler)completion {
    
    NSNumber* volumeValue = @(MIN(MAX(0, volume), 100));
    SENSleepSoundRequestPlay* request
        = [[SENSleepSoundRequestPlay alloc] initWithSoundId:[sound identifier]
                                                 durationId:[duration identifier]
                                                     volume:volumeValue];
    
    [[self apiQueue] addOperation:[self operationForRequest:request completion:completion]];
}

- (void)stopPlaying:(HEMSleepSoundsRequestHandler)completion {
    [[self apiQueue] addOperation:[self operationForRequest:[SENSleepSoundRequestStop new]
                                                 completion:completion]];
}

- (BOOL)isEnabled:(SENSleepSoundsState*)soundState {
    return [[soundState sounds] state] == SENSleepSoundsFeatureStateOK;
}

#pragma mark - Sense

- (BOOL)isSenseLastSeenGoingToBeAProblem:(NSDate*)senseLastSeenDate {
    if (!senseLastSeenDate) {
        return NO; // if no date, be optimistic.  assume data just not ready
    }
    
    NSTimeInterval timeInSecsSinceNow = [senseLastSeenDate timeIntervalSinceNow];
    return timeInSecsSinceNow < -HEMSleepSoundServiceSenseLastSeeenThreshold;
}

@end
