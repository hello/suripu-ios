//
//  HEMDeviceCenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/1/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENSense.h>
#import <SenseKit/SENDevice.h>
#import <SenseKit/SENAPIDevice.h>

#import "HEMDeviceCenter.h"

static NSString* const kHEMDeviceCenterErrorDomain = @"is.hello.app.device";

@interface HEMDeviceCenter()

@property (nonatomic, strong) SENDevice* pillInfo;
@property (nonatomic, strong) SENDevice* senseInfo;
@property (nonatomic, strong) SENSenseManager* senseManager;

@property (nonatomic, assign, getter=isInfoLoaded) BOOL infoLoaded; // in case it was loaded, but not paired
@property (nonatomic, assign, getter=isLoadingInfo) BOOL loadingInfo;


@end

@implementation HEMDeviceCenter

+ (instancetype)sharedCenter {
    static HEMDeviceCenter* center = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        center = [[super allocWithZone:NULL] init];
    });
    return center;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedCenter];
}

+ (BOOL)isBluetoothOn {
    return [SENSenseManager isBluetoothOn];
}

- (void)clearCache {
    [self setPillInfo:nil];
    [self setSenseInfo:nil];
    [self setSenseManager:nil];
    [self setInfoLoaded:NO];
    [self setLoadingInfo:NO];
}

- (NSError*)errorWithType:(HEMDeviceCenterError)type {
    return [NSError errorWithDomain:kHEMDeviceCenterErrorDomain
                               code:type
                           userInfo:nil];
}

#pragma mark - Device Info

- (void)loadDeviceInfo:(void(^)(NSError* error))completion {
    if ([self isInfoLoaded]) {
        if (completion) completion( nil );
        return;
    }
    
    [self setLoadingInfo:YES];
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice getPairedDevices:^(NSArray* devicesInfo, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error == nil) {
                [strongSelf processDeviceInfo:devicesInfo];
                [strongSelf setInfoLoaded:YES];
            }
            [strongSelf setLoadingInfo:NO];
        }
        if (completion) completion( error );
    }];
}

- (void)processDeviceInfo:(NSArray*)devicesInfo {
    // TODO (jimmy): for now, let's find the last Sense and last Pill, if any,
    // and assume these are the actual devices the user is using in case there
    // are multiple.  What we probably want to do is to sort the list by last
    // seen and take the most recently last seen of both the Sense and Pill
    SENDevice* device = nil;
    NSInteger i = [devicesInfo count] - 1;
    while (i >= 0 && ([self senseInfo] == nil || [self pillInfo] == nil)) {
        device = [devicesInfo objectAtIndex:i];
        if ([self pillInfo] == nil && [device type] == SENDeviceTypePill) {
            [self setPillInfo:device];
        } else if ([self senseInfo] == nil && [device type] == SENDeviceTypeSense) {
            [self setSenseInfo:device];
        }
        i--;
    }
}

- (void)currentSenseRSSI:(void(^)(NSNumber* rssi, NSError* error))completion {
    if (!completion) return; // do nothing
    
    if ([self pairedSenseAvailable]) {
        [[self senseManager] currentRSSI:^(id response) {
            completion (response, nil);
        } failure:^(NSError *error) {
            completion (nil, error);
        }];
    } else {
        completion (nil, [self errorWithType:HEMDeviceCenterErrorSenseUnavailable]);
    }
}

#pragma mark - Scanning

- (void)scanForPairedSense:(void(^)(NSError* error))completion {
    if ([self senseManager] != nil) { // already loaded?  just complete
        
        if (completion) completion (nil);
        
    } else if ([self senseInfo] != nil) { // has info?  find Sense nearby
        
        [self findAndManageSense:completion];
        
    } else if (![self isInfoLoaded]) { // no info yet?  load the info, then find sense
        
        __weak typeof(self) weakSelf = self;
        [self loadDeviceInfo:^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error != nil) {
                if (completion) completion (error);
                return;
            }
            
            if (strongSelf && [strongSelf senseInfo] != nil) {
                [strongSelf findAndManageSense:completion];
            }
        }];
        
    } else if ([self senseInfo] == nil) { // loaded, but still no info?
        
        if (completion) completion ([self errorWithType:HEMDeviceCenterErrorSenseNotPaired]);
        
    } else { // what else can actually happen?
        if (completion) completion( nil );
    }
}

- (void)findAndManageSense:(void(^)(NSError* error))completion {
    if (![SENSenseManager isReady]) {
        [self performSelector:@selector(findAndManageSense:)
                   withObject:completion
                   afterDelay:0.1f];
        return;
    }
    
    if ([SENSenseManager isScanning]) {
        [SENSenseManager stopScan]; // stop it, then go again
    }
    
    __weak typeof(self) weakSelf = self;
    [SENSenseManager scanForSense:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if ([senses count] > 0) {
            NSString* lowerDeviceId = nil;
            NSString* lowerInfoDeviceId = [[[strongSelf senseInfo] deviceId] lowercaseString];
            for (SENSense* sense in senses) {
                lowerDeviceId = [[sense deviceId] lowercaseString];
                if ([lowerInfoDeviceId isEqualToString:lowerDeviceId]) {
                    [strongSelf setSenseManager:[[SENSenseManager alloc] initWithSense:sense]];
                    break;
                }
            }
        }
        
        if (completion) {
            NSError* error = nil;
            if ([strongSelf senseManager] == nil) {
                error = [strongSelf errorWithType:HEMDeviceCenterErrorSenseUnavailable];
            }
            completion( error );
        }

    }];
}

- (void)stopScanning {
    [SENSenseManager stopScan];
}

#pragma mark - Pairing

- (BOOL)pairedSenseAvailable {
    return [self senseManager] != nil;
}

- (void)putSenseIntoPairingMode:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    if ([self pairedSenseAvailable]) {
        
        [[self senseManager] enablePairingMode:YES success:^(id response) {
            if (completion) completion (nil);
        } failure:completion];
        
    } else if ([SENSenseManager isScanning]) {
        if (completion) completion ([self errorWithType:HEMDeviceCenterErrorScanInProgress]);
    } else {
        
        [self scanForPairedSense:^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if ([strongSelf senseManager] != nil) {
                    [strongSelf putSenseIntoPairingMode:completion];
                } else {
                    if (completion) {
                        completion ([strongSelf errorWithType:HEMDeviceCenterErrorSenseUnavailable]);
                    }
                }
            }

        }];
    }
}

#pragma mark Unpairing Sleep Pill

- (void)unpairPillFromSense:(HEMDeviceCompletionBlock)completion {
    [[self senseManager] unpairPill:[[self pillInfo] deviceId] success:^(id response) {
        if (completion) completion (nil);
    } failure:completion];
}

- (void)unlinkPillFromAccount:(HEMDeviceCompletionBlock)completion {
    [SENAPIDevice unregisterPill:[self pillInfo] completion:^(id data, NSError *error) {
        if (completion) completion (error);
    }];
}

- (void)unpairSleepPillFromSenseThenAccount:(HEMDeviceCompletionBlock)completion {
    __weak typeof(self) weakSelf = self;
    [self unpairPillFromSense:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error == nil) {
                [strongSelf unlinkPillFromAccount:^(NSError *error) {
                    NSError* deviceError = nil;
                    if (error != nil) {
                        error = [strongSelf errorWithType:HEMDeviceCenterErrorUnlinkPillFromAccount];
                    }
                    if (completion) completion (deviceError);
                }];
            } else {
                if (completion) {
                    completion ([strongSelf errorWithType:HEMDeviceCenterErrorUnpairPillFromSense]);
                }
            }
        }
    }];
}

- (NSError*)preconditionsErrorForUnpairingPill {
    NSError* error = nil;
    if ([self pillInfo] == nil) {
        error = [self errorWithType:HEMDeviceCenterErrorPillNotPaired];
    } else if ([self senseInfo] == nil) {
        error = [self errorWithType:HEMDeviceCenterErrorSenseNotPaired];
    }
    return error;
}

- (void)unpairSleepPill:(HEMDeviceCompletionBlock)completion {
    NSError* error = [self preconditionsErrorForUnpairingPill];
    if (error != nil) {
        if (completion) completion ( error );
        return;
    }
    
    if (![self pairedSenseAvailable]) {
        __weak typeof(self) weakSelf = self;
        [self scanForPairedSense:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if (error == nil) {
                    [strongSelf unpairSleepPillFromSenseThenAccount:completion];
                } else {
                    if (completion) {
                        completion ([strongSelf  errorWithType:HEMDeviceCenterErrorSenseUnavailable]);
                    }
                }
            }
        }];
    } else {
        [self unpairSleepPillFromSenseThenAccount:completion];
    }
}

@end