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
#import <SenseKit/SENLocalPreferences.h>

#import "HEMSleepSoundService.h"
#import "HEMSleepSoundVolume.h"
#import "HEMSleepSoundActionOperation.h"
#import "HEMSleepSoundStatusCheckOperation.h"

NSString* const HEMSleepSoundServiceErrorDomain = @"is.hello.sense.sleep-sound";
NSString* const HEMSleepSoundServiceNotifyStatus = @"HEMSleepSoundServiceNotifyStatus";
NSString* const HEMSleepSoundServiceNotifyInfoStatus = @"status";

static CGFloat const HEMSleepSoundServiceVolumeHigh = 100.0f;
static CGFloat const HEMSleepSoundServiceVolumeMedium = 50.0f;
static CGFloat const HEMSleepSoundServiceVolumeLow = 25.0f;
static CGFloat const HEMSleepSoundServiceVolumeAccuracy = 5.0f;
static CGFloat const HEMSleepSoundServiceSenseLastSeeenThreshold = 1800.0f; // 30 minutes
static CGFloat const HEMSleepSoundServiceMonitorInterval = 0.5f; // in secs (500 ms)

static NSString* const HEMSleepSoundSettingLastSoundId = @"sleep-sound.soundId";
static NSString* const HEMSleepSoundSettingLastVolume = @"sleep-sound.volume";
static NSString* const HEMSleepSoundSettingLastDurationId = @"sleep-sound.durationId";

@interface HEMSleepSoundService()

@property (nonatomic, strong) NSOperationQueue* apiQueue;
@property (nonatomic, strong) NSArray<HEMSleepSoundVolume*>* availableVolumeOptions;
@property (nonatomic, assign) BOOL stopMonitoring;

@end

@implementation HEMSleepSoundService

- (instancetype)init {
    self = [super init];
    if (self) {
        _stopMonitoring = YES;
        _apiQueue = [NSOperationQueue new];
        [_apiQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

#pragma mark - local preferences / settings

- (id)lastSavedSoundSettingFor:(NSString*)key {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    return [prefs userPreferenceForKey:key];
}

- (void)saveSoundSetting:(id)setting withKey:(NSString*)key {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    [prefs setUserPreference:setting forKey:key];
}

- (void)saveSelectedSoundSetting:(SENSleepSound*)sound {
    if ([sound identifier]) {
        [self saveSoundSetting:[sound identifier]
                       withKey:HEMSleepSoundSettingLastSoundId];
    }
}

- (void)saveSelectedDurationSetting:(SENSleepSoundDuration*)duration {
    if ([duration identifier]) {
        [self saveSoundSetting:[duration identifier]
                       withKey:HEMSleepSoundSettingLastDurationId];
    }
}

- (void)saveSelectedVolumeSetting:(HEMSleepSoundVolume*)volume {
    if (volume) {
        [self saveSoundSetting:@([volume volume])
                       withKey:HEMSleepSoundSettingLastVolume];
    }
}

#pragma mark -

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

- (HEMSleepSoundVolume*)volumeObjectThatMatches:(NSNumber*)volumeValue {
    if (!volumeValue) {
        return nil;
    }
    
    NSArray<HEMSleepSoundVolume*>* volumes = [self availableVolumeOptions];
    HEMSleepSoundVolume* volumeObject = nil;
    for (HEMSleepSoundVolume* volume in volumes) {
        CGFloat value = [volumeValue CGFloatValue];
        // values returned from the server may not be 100% accurate.  We may need
        // to have this type of logic put on the server and agree on some enums
        // in the future
        if (([volume volume] >= value - HEMSleepSoundServiceVolumeAccuracy)
            && [volume volume] <= value + HEMSleepSoundServiceVolumeAccuracy) {
            volumeObject = volume;
            break;
        }
    }
    
    return volumeObject;
}

- (HEMSleepSoundVolume*)volumeObjectForValue:(NSNumber*)value {
    HEMSleepSoundVolume* volume = [self volumeObjectThatMatches:value];
    return volume ?: [self defaultVolume];
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
    NSString* key = HEMSleepSoundSettingLastSoundId;
    NSNumber* lastSavedId = [self lastSavedSoundSettingFor:key];
    SENSleepSound* defaultSound = nil;
    if (lastSavedId) {
        for (SENSleepSound* sound in [available sounds]) {
            if ([[sound identifier] isEqualToNumber:lastSavedId]) {
                defaultSound = sound;
                break;
            }
        }
    }
    return defaultSound ?: [[available sounds] firstObject];
}

- (SENSleepSoundDuration*)defaultDurationFrom:(SENSleepSoundDurations*)available {
    NSString* key = HEMSleepSoundSettingLastDurationId;
    NSNumber* lastSavedId = [self lastSavedSoundSettingFor:key];
    SENSleepSoundDuration* defaultDuration = nil;
    if (lastSavedId) {
        for (SENSleepSoundDuration* duration in [available durations]) {
            if ([[duration identifier] isEqualToNumber:lastSavedId]) {
                defaultDuration = duration;
                break;
            }
        }
    }
    return defaultDuration ?: [[available durations] firstObject];
}

- (HEMSleepSoundVolume*)defaultVolume {
    NSString* key = HEMSleepSoundSettingLastVolume;
    NSNumber* lastSavedVolume = [self lastSavedSoundSettingFor:key];
    HEMSleepSoundVolume* volume = nil;
    if (lastSavedVolume) {
        volume = [self volumeObjectThatMatches:lastSavedVolume];
    }
    if (!volume) {
        // take the middle
        NSInteger mid = [[self availableVolumeOptions] count] / 2;
        volume = [self availableVolumeOptions][mid];
    }
    return volume;
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

#pragma mark - Monitor

- (void)startMonitoringStatusChange {
    BOOL started = NO;
    for (NSOperation* op in [[self apiQueue] operations]) {
        if ([op isKindOfClass:[HEMSleepSoundStatusCheckOperation class]]) {
            started = YES;
            break;
        }
    }
    if (!started) {
        DDLogVerbose(@"not started yet, start monitoring sleep sound status");
        [self setStopMonitoring:NO];
        [self doAnotherCheck];
    } else {
        DDLogVerbose(@"sleep sound status monitor already started");
    }
}

- (HEMSleepSoundStatusCheckOperation*)statusCheckOp {
    __weak typeof(self) weakSelf = self;
    HEMSleepSoundStatusCheckOperation* op = [HEMSleepSoundStatusCheckOperation new];
    [op setResultCompletionBlock:^(SENSleepSoundStatus* status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf notifyOfStatus:status];
        [strongSelf doAnotherCheck];
    }];
    return op;
}

- (void)notifyOfStatus:(SENSleepSoundStatus*)status {
    if (status) {
        NSDictionary* info = @{HEMSleepSoundServiceNotifyInfoStatus : status};
        NSNotification* note
            = [NSNotification notificationWithName:HEMSleepSoundServiceNotifyStatus
                                            object:self
                                          userInfo:info];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    }
}

- (void)doAnotherCheck {
    if ([self stopMonitoring]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    CGFloat delay = HEMSleepSoundServiceMonitorInterval;
    DDLogVerbose(@"checking next request after delay %f, op count %ld",
                 delay,
                 [[self apiQueue] operationCount]);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf apiQueue] addOperation:[strongSelf statusCheckOp]];
    });
}

- (void)stopMonitoringStatusChange {
    [self setStopMonitoring:YES];
    for (NSOperation* op in [[self apiQueue] operations]) {
        if ([op isKindOfClass:[HEMSleepSoundStatusCheckOperation class]]) {
            [op cancel];
        }
    }
}

#pragma mark - Sense

- (BOOL)isSenseLastSeenGoingToBeAProblem:(NSDate*)senseLastSeenDate {
    if (!senseLastSeenDate) {
        return NO; // if no date, be optimistic.  assume data just not ready
    }
    
    NSTimeInterval timeInSecsSinceNow = [senseLastSeenDate timeIntervalSinceNow];
    return timeInSecsSinceNow < -HEMSleepSoundServiceSenseLastSeeenThreshold;
}

#pragma mark - Clean up

- (void)dealloc {
    if (_apiQueue) {
        [_apiQueue cancelAllOperations];
    }
}

@end
