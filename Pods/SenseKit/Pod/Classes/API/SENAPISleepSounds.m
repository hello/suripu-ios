//
//  SENAPISleepSounds.m
//  Pods
//
//  Created by Jimmy Lu on 3/8/16.
//
//

#import "SENAPISleepSounds.h"
#import "SENSleepSoundDurations.h"
#import "SENSleepSounds.h"
#import "SENSleepSoundStatus.h"
#import "SENSleepSoundRequest.h"

static NSString* const SENAPISleepSoundsResource = @"v2/sleep_sounds";
static NSString* const SENAPISleepSoundsPathAvailable = @"sounds";
static NSString* const SENAPISleepSoundsPathDuration = @"durations";
static NSString* const SENAPISleepSoundsPathStatus = @"status";
static NSString* const SENAPISleepSoundsPathActionStop = @"stop";
static NSString* const SENAPISleepSoundsPathActionPlay = @"play";

@implementation SENAPISleepSounds

+ (void)availableSleepSounds:(SENAPIDataBlock)completion {
    NSString* path = [SENAPISleepSoundsResource stringByAppendingPathComponent:SENAPISleepSoundsPathAvailable];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        SENSleepSounds* sounds = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            sounds = [[SENSleepSounds alloc] initWithDictionary:data];
        }
        completion (sounds, error);
    }];
}

+ (void)availableDurations:(SENAPIDataBlock)completion {
    NSString* path = [SENAPISleepSoundsResource stringByAppendingPathComponent:SENAPISleepSoundsPathDuration];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        SENSleepSoundDurations* sounds = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            sounds = [[SENSleepSoundDurations alloc] initWithDictionary:data];
        }
        completion (sounds, error);
    }];
}

+ (void)executeRequest:(SENSleepSoundRequest*)request completion:(SENAPIErrorBlock)completion {
    NSDictionary* param = [request dictionaryValue];
    NSString* path = SENAPISleepSoundsResource;
    
    if ([request isKindOfClass:[SENSleepSoundRequestPlay class]]) {
        path = [path stringByAppendingPathComponent:SENAPISleepSoundsPathActionPlay];
    } else {
        path = [path stringByAppendingPathComponent:SENAPISleepSoundsPathActionStop];
    }
    
    [SENAPIClient POST:path parameters:param completion:^(id data, NSError *error) {
        completion (error);
    }];
}

+ (void)checkRequestStatus:(SENAPIDataBlock)completion {
    NSString* path = [SENAPISleepSoundsResource stringByAppendingPathComponent:SENAPISleepSoundsPathStatus];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        SENSleepSoundStatus* status = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            status = [[SENSleepSoundStatus alloc] initWithDictionary:data];
        }
        completion (status, error);
    }];
}

@end
