//
//  SENServiceDevice.m
//  Pods
//
//  Created by Jimmy Lu on 12/29/14.
//
//

#import "SENServiceDevice.h"
#import "SENAuthorizationService.h"
#import "SENSenseManager.h"
#import "SENSense.h"
#import "SENAPIDevice.h"
#import "SENService+Protected.h"
#import "SENSenseWiFiStatus.h"
#import "SENDeviceMetadata.h"
#import "SENPairedDevices.h"
#import "SENPillMetadata.h"
#import "SENSenseMetadata.h"

NSString* const SENServiceDeviceNotificationFactorySettingsRestored = @"sense.restored";
NSString* const SENServiceDeviceNotificationSenseUnpaired = @"sense.unpaired";
NSString* const SENServiceDeviceNotificationPillUnpaired = @"pill.unpaired";
NSString* const SENServiceDeviceErrorDomain = @"is.hello.service.device";

@interface SENServiceDevice()

@property (nonatomic, strong) SENPairedDevices* devices;
@property (nonatomic, strong) SENSenseManager* senseManager;

@property (nonatomic, assign, getter=isInfoLoaded) BOOL infoLoaded; // in case it was loaded, but not paired

@end

@implementation SENServiceDevice

+ (instancetype)sharedService {
    static SENServiceDevice* center = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        center = [[super allocWithZone:NULL] init];
    });
    return center;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedService];
}

#pragma mark -

- (void)reset {
    [SENSenseManager stopScan];
    
    [self setDevices:nil];
    [self setSenseManager:nil];
    [self setInfoLoaded:NO];
}

- (NSError*)errorWithType:(SENServiceDeviceError)type {
    return [NSError errorWithDomain:SENServiceDeviceErrorDomain
                               code:type
                           userInfo:nil];
}

- (void)whenPairedSenseIsReadyDo:(void(^)(NSError* error))completion {
    if (!completion) return;
    
    if (![[self devices] hasPairedSense]) {
        
        completion ([self errorWithType:SENServiceDeviceErrorSenseNotPaired]);
        
    } else if ([self pairedSenseAvailable]) {
        
        completion (nil);
        
    } else if ([SENSenseManager isScanning]) {
        
        completion ([self errorWithType:SENServiceDeviceErrorInProgress]);
        
    } else {
        
        __weak typeof(self) weakSelf = self;
        [self scanForPairedSense:^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if ([strongSelf senseManager] != nil) {
                    completion (nil);
                } else {
                    completion ([strongSelf errorWithType:SENServiceDeviceErrorSenseUnavailable]);
                }
            }
            
        }];
    }
}

#pragma mark - Device Info

- (void)loadDeviceInfo:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice getPairedDevices:^(SENPairedDevices* devices, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf setDevices:devices];
            [strongSelf setInfoLoaded:YES];
        }
        
        if (completion) {
            completion (error);
        }
    }];
}

- (void)getConfiguredWiFi:(void(^)(NSString* ssid, SENSenseWiFiStatus* status,  NSError* error))completion {
    if (!completion) return;
    
    __weak typeof(self) weakSelf = self;
    [self whenPairedSenseIsReadyDo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil) {
                completion (nil, nil, error);
                return;
            }
            
            [[strongSelf senseManager] getConfiguredWiFi:^(NSString* ssid, SENSenseWiFiStatus* status) {
                completion (ssid, status, nil);
            } failure:^(NSError *error) {
                completion (nil, nil, error);
            }];
        }
    }];
}

- (BOOL)shouldWarnAboutLastSeenForDevice:(SENDeviceMetadata*)metadata {
    if (metadata == nil) return NO;
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [NSDateComponents new];
    components.day = -1;
    
    NSDate* dayOld = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    return [[metadata lastSeenDate] compare:dayOld] == NSOrderedAscending;
}

- (BOOL)shouldWarnAboutPillLastSeen {
    return [self shouldWarnAboutLastSeenForDevice:[[self devices] pillMetadata]];
}

- (BOOL)shouldWarnAboutSenseLastSeen {
    return [self shouldWarnAboutLastSeenForDevice:[[self devices] senseMetadata]];
}

#pragma mark - Scanning

- (void)scanForPairedSense:(void(^)(NSError* error))completion {
    void(^done)(NSError* error) = ^(NSError* error){
        if (completion) {
            completion (error);
        }
    };
    
    if ([self senseManager] != nil) { // already loaded?  just complete
        
        done (nil);
        
    } else if (![SENSenseManager canScan]) {
        
        done ([self errorWithType:SENServiceDeviceErrorBLEUnavailable]);
        
    } else if ([[self devices] hasPairedSense]) {
        
        [self findAndManageSense:done];
        
    } else if (![self isInfoLoaded]) { // no info yet?  load the info, then find sense
        
        __weak typeof(self) weakSelf = self;
        [self loadDeviceInfo:^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error != nil) {
                done (error);
                return;
            }
            
            if ([[strongSelf devices] hasPairedSense]) {
                [strongSelf findAndManageSense:done];
            } else {
                done ([strongSelf errorWithType:SENServiceDeviceErrorSenseNotPaired]);
            }
        }];
        
    } else if (![[self devices] hasPairedSense]) { // loaded, but still no info?
        
        done ([self errorWithType:SENServiceDeviceErrorSenseNotPaired]);
        
    } else { // what else can actually happen?
        done( nil );
    }
}

- (BOOL)senseIsTheOnePairedToAccount:(SENSense*)sense {
    if (!sense || ![[self devices] hasPairedSense]) {
        return NO;
    }
    
    SENSenseMetadata* senseMetadata = [[self devices] senseMetadata];
    NSString* pairedDeviceId = [[senseMetadata uniqueId] lowercaseString];
    NSString* senseDeviceId = [[sense deviceId] lowercaseString];
    return [pairedDeviceId isEqualToString:senseDeviceId];
}

- (void)findAndManageSense:(void(^)(NSError* error))completion {
    if (![SENSenseManager isReady]) {
        [self performSelector:@selector(findAndManageSense:)
                   withObject:completion
                   afterDelay:0.1f];
        return;
    }
    
    if ([SENSenseManager isScanning]) {
        [SENSenseManager stopScan];
    }
    
    __weak typeof(self) weakSelf = self;
    [SENSenseManager lastConnectedSense:^(SENSense *sense, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error && [strongSelf senseIsTheOnePairedToAccount:sense]) {
            [strongSelf setSenseManager:[[SENSenseManager alloc] initWithSense:sense]];
            completion (nil);
        } else if ([error code] == SENSenseManagerErrorCodeNoBLE) {
            completion (error);
        } else { // if any other error or sense not the one paired, scan for it
            [strongSelf scan:completion];
        }
    }];
}

- (void)scan:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENSenseManager scanForSense:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ([senses count] > 0) {
            for (SENSense* sense in senses) {
                if ([strongSelf senseIsTheOnePairedToAccount:sense]) {
                    [strongSelf setSenseManager:[[SENSenseManager alloc] initWithSense:sense]];
                    break;
                }
            }
        } else {
            // if another scan was issued and we now no longer find a sense, we
            // need to make sure this service reflects this condition
            [strongSelf setSenseManager:nil];
        }
        
        NSError* error = nil;
        if ([strongSelf senseManager] == nil) {
            error = [strongSelf errorWithType:SENServiceDeviceErrorSenseUnavailable];
        }
        completion( error );
        
    }];
}

- (void)stopScanning {
    [SENSenseManager stopScan];
}

#pragma mark - Pairing

- (BOOL)pairedSenseAvailable {
    return [[self senseManager] sense] != nil
        && [self senseIsTheOnePairedToAccount:[[self senseManager] sense]];
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

- (void)notifyPillUnpaired {
    NSString* name = SENServiceDeviceNotificationPillUnpaired;
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

- (void)unpairSleepPill:(SENServiceDeviceCompletionBlock)completion {
    void(^done)(NSError* error) = ^(NSError* error) {
        if (completion) {
            completion (error);
        }
    };
    
    if (![[self devices] hasPairedPill]) {
        done ( [self errorWithType:SENServiceDeviceErrorPillNotPaired] );
        return;
    }
    
    SENPillMetadata* pillMetadata = [[self devices] pillMetadata];
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice unregisterPill:pillMetadata completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSError* deviceError = error;
        if (error != nil) {
            deviceError = [strongSelf errorWithType:SENServiceDeviceErrorUnlinkPillFromAccount];
        } else {
            [[strongSelf devices] removePairedPill];
            [strongSelf notifyPillUnpaired];
        }
        
        done (deviceError);
    }];
}

#pragma mark Unlink Sense From account

- (void)notifySenseUnpaired {
    NSString* name = SENServiceDeviceNotificationSenseUnpaired;
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

- (void)unlinkSenseFromAccount:(SENServiceDeviceCompletionBlock)completion {
    void(^done)(NSError* error) = ^(NSError* error) {
        if (completion) {
            completion (error);
        }
    };
    
    if (![[self devices] hasPairedSense]) {
        done ([self errorWithType:SENServiceDeviceErrorSenseNotPaired]);
        return;
    }
    
    SENSenseMetadata* senseMetadata = [[self devices] senseMetadata];
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice unregisterSense:senseMetadata completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSError* deviceError = nil;
        
        if (error != nil) {
            deviceError = [strongSelf errorWithType:SENServiceDeviceErrorUnlinkSenseFromAccount];
        } else {
            [[strongSelf senseManager] disconnectFromSense];
            [[strongSelf devices] removePairedSense];
            [strongSelf setSenseManager:nil];
            [strongSelf notifySenseUnpaired];
        }
        
        done (deviceError);
    }];
}

#pragma mark Factory Settings

- (void)notifyFactoryRestore {
    NSString* name = SENServiceDeviceNotificationFactorySettingsRestored;
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

- (void)restoreFactorySettings:(SENServiceDeviceCompletionBlock)completion {
    void(^done)(NSError* error) = ^(NSError* error) {
        if (completion) {
            completion (error);
        }
    };
    
    if (![[self devices] hasPairedSense]) {
        done ([self errorWithType:SENServiceDeviceErrorSenseUnavailable]);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void(^turnOffLedThenFail)(NSError* error) = ^(NSError* error) {
        [weakSelf setLEDState:SENSenseLEDStateOff completion:^(__unused NSError *ledError) {
            done (error);
        }];
    };
    // per discussion, we should reverse the logic as the unlinking of devices
    // currently appear to be less reliable and so we need to exit if anything
    // fails before resetting the firmware
    //
    // should make sure sense is even nearby, though, before we begin
    [self whenPairedSenseIsReadyDo:^(NSError *error) {
        __block typeof(weakSelf) blockSelf = weakSelf;
        
        if (error != nil) {
            done (error);
            return;
        }
        
        [blockSelf setLEDState:SENSenseLEDStateActivity completion:^(NSError *error) {
            if (error != nil) {
                done (error);
                return;
            }
            
            SENSenseMetadata* senseMetadata = [[blockSelf devices] senseMetadata];
            [SENAPIDevice removeAssociationsToSense:senseMetadata completion:^(__unused id data, NSError *error) {
                if (error != nil) {
                    turnOffLedThenFail(error);
                    return;
                }
                
                [[blockSelf senseManager] resetToFactoryState:^(__unused id response) {
                    [[blockSelf senseManager] disconnectFromSense];
                    [blockSelf reset];
                    [blockSelf notifyFactoryRestore];
                    done (nil);
                } failure:turnOffLedThenFail];
            }];
            
        }];
        
    }];
}

#pragma mark - LED

- (void)setLEDState:(SENSenseLEDState)state
         completion:(SENServiceDeviceCompletionBlock)completion {
    
    __strong typeof(self) weakSelf = self;
    [self whenPairedSenseIsReadyDo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            if (completion) completion (error);
            return;
        }
        
        [[strongSelf senseManager] setLED:state completion:^(id response, NSError *error) {
            if (completion) completion (error);
        }];
    }];
    
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
