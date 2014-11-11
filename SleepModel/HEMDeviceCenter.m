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

NSString* const kHEMDeviceNotificationFactorySettingsRestored = @"sense.restored";

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

- (void)whenPairedSenseIsReadyDo:(void(^)(NSError* error))completion {
    if (!completion) return;
    
    __weak typeof(self) weakSelf = self;
    if ([self pairedSenseAvailable]) {
        
        completion (nil);
        
    } else if ([SENSenseManager isScanning]) {
        
        completion ([self errorWithType:HEMDeviceCenterErrorInProgress]);
        
    } else {
        
        [self scanForPairedSense:^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if ([strongSelf senseManager] != nil) {
                    completion (nil);
                } else {
                    completion ([strongSelf errorWithType:HEMDeviceCenterErrorSenseUnavailable]);
                }
            }
            
        }];
    }
}

#pragma mark - Device Info

- (void)loadDeviceInfo:(void(^)(NSError* error))completion {
    if ([self isLoadingInfo]) {
        if (completion) completion ([self errorWithType:HEMDeviceCenterErrorInProgress]);
        return;
    }

    // no need to set InfoLoaded to NO here b/c we will not clear the cache unless
    // caller explicitly calls clear or when response comes back without error.
    
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
    // first, clear the currently cached info so it will actually update
    [self setPillInfo:nil];
    [self setSenseInfo:nil];
    
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

- (void)getConfiguredWiFi:(void(^)(NSString* ssid, SENWiFiConnectionState state,  NSError* error))completion {
    if (!completion) return;
    
    __weak typeof(self) weakSelf = self;
    [self whenPairedSenseIsReadyDo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil) {
                completion (nil, SENWiFiConnectionStateUnknown, error);
                return;
            }
            
            [[strongSelf senseManager] getConfiguredWiFi:^(NSString* ssid, SENWiFiConnectionState state) {
                completion (ssid, state, nil);
            } failure:^(NSError *error) {
                completion (nil, SENWiFiConnectionStateUnknown, error);
            }];
        }
    }];
}

#pragma mark - Scanning

- (void)scanForPairedSense:(void(^)(NSError* error))completion {
    if ([self senseManager] != nil) { // already loaded?  just complete
        
        if (completion) completion (nil);
        
    } else if (![SENSenseManager canScan]) { // has info?  find Sense nearby
        
        if (completion) completion ([self errorWithType:HEMDeviceCenterErrorBLEUnavailable]);
        
    } else if (![SENSenseManager isReady]) { // has info?  find Sense nearby
        // if it's not ready for scanning, try again in a bit
        return [self performSelector:@selector(scanForPairedSense:)
                          withObject:completion
                          afterDelay:0.1f];
        
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
    [self whenPairedSenseIsReadyDo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            if (completion) completion(error);
            return;
        }
        [[strongSelf senseManager] enablePairingMode:YES success:^(id response) {
            // must disconnect from sense to actually allow other person to pair
            [[strongSelf senseManager] disconnectFromSense];
            if (completion) completion (nil);
        } failure:^(NSError *error) {
            if (completion) completion (error);
        }];
    }];
}

#pragma mark Unpairing Sleep Pill

- (void)unpairSleepPill:(HEMDeviceCompletionBlock)completion {
    if ([self pillInfo] == nil) {
        if (completion) completion ( [self errorWithType:HEMDeviceCenterErrorPillNotPaired] );
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice unregisterPill:[self pillInfo] completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSError* deviceError = nil;
        
        if (strongSelf) {
            if (error != nil) {
                deviceError = [strongSelf errorWithType:HEMDeviceCenterErrorUnlinkPillFromAccount];
            } else {
                [strongSelf setPillInfo:nil];
            }
        }
        
        if (completion) completion (deviceError);
    }];
}

#pragma mark Unlink Sense From account

- (void)unlinkSenseFromAccount:(HEMDeviceCompletionBlock)completion {
    if ([self senseInfo] == nil) {
        if (completion) completion ( [self errorWithType:HEMDeviceCenterErrorSenseNotPaired]);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice unregisterSense:[self senseInfo] completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSError* deviceError = nil;
        
        if (error != nil && strongSelf) {
            deviceError = [strongSelf errorWithType:HEMDeviceCenterErrorUnlinkPillFromAccount];
        }
        
        if (completion) completion (deviceError);
    }];
}

#pragma mark Factory Settings

- (void)unlinkAllDevices:(HEMDeviceCompletionBlock)completion {
    // so... we can unlink Sense and the Sleep Pill simulataneously, which will
    // save a bit of time.  However, the actual operations on the server are quick
    // so time saved is really based on the connection.  If the connection is good,
    // then running the two actions serially will likely not take much more time
    // then running them simultaneously since 1 action will have to turn on the radio
    // (if not already fired up) and the radio + connection pool will be "warmed up"
    // for the second call  Serial calls will benefit from less logic and/or avoids
    // having to synchronize any data to call the completion call when both are done.
    //
    // serial it is!, unless we starting seeing this to take too long
    DDLogVerbose(@"unlinking devices started at %@", [NSDate date]);
    __weak typeof(self) weakSelf = self;
    [self unlinkSenseFromAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil && [error code] != HEMDeviceCenterErrorSenseNotPaired) {
                if (completion) {
                    DDLogVerbose(@"unlinking sense ended at %@ with error", [NSDate date]);
                    completion ([strongSelf errorWithType:HEMDeviceCenterErrorUnlinkSenseFromAccount]);
                }
                return;
            }
            
            if ([strongSelf pillInfo] != nil) {
                [strongSelf unpairSleepPill:^(NSError *error) {
                    if (error != nil) {
                        if (completion) {
                            DDLogVerbose(@"unlinking pill ended at %@ with error", [NSDate date]);
                            completion ([strongSelf errorWithType:HEMDeviceCenterErrorUnlinkPillFromAccount]);
                        }
                        return;
                    }
                    
                    DDLogVerbose(@"unlinking devices ended at %@ successfully", [NSDate date]);
                    if (completion) completion (nil);
                }];
            } else {
                if (completion) completion (nil);
            }

        }
    }];
}

- (void)notifyFactoryRestore {
    NSString* name = kHEMDeviceNotificationFactorySettingsRestored;
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

- (void)resetSense:(HEMDeviceCompletionBlock)completion {
    if ([self senseManager] == nil) {
        if (completion) completion (nil);
    } else {
        [[self senseManager] resetToFactoryState:^(id response) {
            if (completion) {
                completion (nil);
            }
        } failure:completion];
    }
}

- (void)restoreFactorySettings:(HEMDeviceCompletionBlock)completion {
    
    if ([SENSenseManager isScanning]) {
        
        if (completion) completion ([self errorWithType:HEMDeviceCenterErrorInProgress]);
        
    } else {
        
        __weak typeof(self) weakSelf = self;
        [self resetSense:^(NSError *error) {
            if (error) {
                if (completion) completion (error);
                return;
            }
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                // required.  firmware will actually just reply it succeeded, but
                // the actual resetting won't happen until it has been disconnected.
                [[strongSelf senseManager] disconnectFromSense];
                [strongSelf setSenseManager:nil];
                
                [strongSelf unlinkAllDevices:^(NSError *error) {
                    if (error != nil) {
                        if (completion) completion (error);
                        return;
                    }
                    
                    [strongSelf clearCache];
                    [strongSelf notifyFactoryRestore];
                    
                    if (completion) completion (nil);
                }];
            }
        }];

    }
    
}

@end
