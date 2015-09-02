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
#import "SENDevice.h"
#import "SENSense.h"
#import "SENAPIDevice.h"
#import "SENService+Protected.h"
#import "SENSenseWiFiStatus.h"

NSString* const SENServiceDeviceNotificationFactorySettingsRestored = @"sense.restored";
NSString* const SENServiceDeviceNotificationWarning = @"sense.warning";
NSString* const SENServiceDeviceErrorDomain = @"is.hello.service.device";

@interface SENServiceDevice()

@property (nonatomic, strong) SENDevice* pillInfo;
@property (nonatomic, strong) SENDevice* senseInfo;
@property (nonatomic, strong) SENSenseManager* senseManager;

@property (nonatomic, assign) SENServiceDeviceState deviceState;

@property (nonatomic, assign, getter=isInfoLoaded) BOOL infoLoaded; // in case it was loaded, but not paired
@property (nonatomic, assign, getter=isLoadingInfo) BOOL loadingInfo;
@property (nonatomic, assign, getter=isCheckingStates) BOOL checkingStates;

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

- (id)init {
    self = [super init];
    if (self) {
        [self setDeviceState:SENServiceDeviceStateUnknown];
    }
    return self;
}

#pragma mark - SENService Overrides

- (void)checkDevicesState:(void(^)(SENServiceDeviceState state))completion {
    if ([SENAuthorizationService isAuthorized] && ![self isCheckingStates] && completion) {
        __weak typeof(self) weakSelf = self;
        [self setCheckingStates:YES];
        [self loadDeviceInfo:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error == nil) {
                [strongSelf checkSenseAndPillState:^(SENServiceDeviceState state) {
                    [strongSelf setDeviceState:state];
                    [strongSelf setCheckingStates:NO];
                    completion (state);
                }];
            } else {
                [strongSelf setCheckingStates:NO];
                completion (SENServiceDeviceStateUnknown);
            }
        }];
    } else {
        [self setCheckingStates:NO];
        if (completion) {
            completion (SENServiceDeviceStateUnknown);
        }
    }
}

#pragma mark - Device State / Warnings

- (void)checkSenseAndPillState:(void(^)(SENServiceDeviceState state))completion {
    __weak typeof(self) weakSelf = self;
    [self checkSenseState:^(SENServiceDeviceState state) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (state == SENServiceDeviceStateNormal) {
            [strongSelf checkPillState:completion];
        } else {
            completion (state);
        }
    }];
}

- (void)checkSenseState:(void(^)(SENServiceDeviceState state))completion {
    SENServiceDeviceState deviceState
        = [self senseInfo] == nil
        ? SENServiceDeviceStateSenseNotPaired
        : SENServiceDeviceStateNormal;
    
    if (deviceState == SENServiceDeviceStateNormal) {
        if ([self shouldWarnAboutSenseLastSeen]) {
            deviceState = SENServiceDeviceStateSenseNotSeen;
        }
    }
    
    if (deviceState == SENServiceDeviceStateNormal) {
        switch ([[self senseInfo] state]) {
            case SENDeviceStateNoData:
                deviceState = SENServiceDeviceStateSenseNoData;
                break;
            default:
                break;
        }
    }
    
    completion (deviceState);
}

- (void)checkPillState:(void(^)(SENServiceDeviceState state))completion {
    SENServiceDeviceState deviceState
        = [self pillInfo] == nil
        ? SENServiceDeviceStatePillNotPaired
        : SENServiceDeviceStateNormal;
    
    if (deviceState == SENServiceDeviceStateNormal) {
        switch ([[self pillInfo] state]) {
            case SENDeviceStateLowBattery:
                deviceState = SENServiceDeviceStatePillLowBattery;
                break;
            default:
                break;
        }
    }
    
    if (deviceState == SENServiceDeviceStateNormal) {
        if ([self shouldWarnAboutPillLastSeen]) {
            deviceState = SENServiceDeviceStatePillNotSeen;
        }
    }
    
    completion (deviceState);
}

#pragma mark -

- (void)resetDeviceStates {
    [self clearCache];
    [self setCheckingStates:NO];
    [self setDeviceState:SENServiceDeviceStateUnknown];
    [SENSenseManager stopScan]; // if it was scannig
}

- (void)clearCache {
    [self setPillInfo:nil];
    [self setSenseInfo:nil];
    [self setSenseManager:nil];
    [self setInfoLoaded:NO];
    [self setLoadingInfo:NO];
}

- (NSError*)errorWithType:(SENServiceDeviceError)type {
    return [NSError errorWithDomain:SENServiceDeviceErrorDomain
                               code:type
                           userInfo:nil];
}

- (void)whenPairedSenseIsReadyDo:(void(^)(NSError* error))completion {
    if (!completion) return;
    
    if ([self senseInfo] == nil) {
        
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
    if ([self isLoadingInfo]) {
        if (completion) completion ([self errorWithType:SENServiceDeviceErrorInProgress]);
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

- (void)loadDeviceInfoIfNeeded:(SENServiceDeviceCompletionBlock)completion {
    if ([self isLoadingInfo]) {
        if (completion)
            completion([self errorWithType:SENServiceDeviceErrorInProgress]);
    } else if ([self isInfoLoaded]) {
        if (completion)
            completion(nil);
    } else {
        [self loadDeviceInfo:completion];
    }
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
        completion (nil, [self errorWithType:SENServiceDeviceErrorSenseUnavailable]);
    }
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

- (BOOL)shouldWarnAboutLastSeenForDevice:(SENDevice*)device {
    if (device == nil) return NO;
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [NSDateComponents new];
    components.day = -1;
    
    NSDate* dayOld = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    return [[device lastSeen] compare:dayOld] == NSOrderedAscending;
}

- (BOOL)shouldWarnAboutPillLastSeen {
    return [self shouldWarnAboutLastSeenForDevice:[self pillInfo]];
}

- (BOOL)shouldWarnAboutSenseLastSeen {
    return [self shouldWarnAboutLastSeenForDevice:[self senseInfo]];
}

#pragma mark - Last Connected Sense

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
        
    } else if ([self senseInfo] != nil) {
        
        [self findAndManageSense:done];
        
    } else if (![self isInfoLoaded]) { // no info yet?  load the info, then find sense
        
        __weak typeof(self) weakSelf = self;
        [self loadDeviceInfo:^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error != nil) {
                done (error);
                return;
            }
            
            if ([strongSelf senseInfo] != nil) {
                [strongSelf findAndManageSense:done];
            } else {
                done ([strongSelf errorWithType:SENServiceDeviceErrorSenseNotPaired]);
            }
        }];
        
    } else if ([self senseInfo] == nil) { // loaded, but still no info?
        
        done ([self errorWithType:SENServiceDeviceErrorSenseNotPaired]);
        
    } else { // what else can actually happen?
        done( nil );
    }
}

- (BOOL)senseIsTheOnePairedToAccount:(SENSense*)sense {
    if (!sense || ![self senseInfo]) {
        return NO;
    }
    
    NSString* pairedDeviceId = [[[self senseInfo] deviceId] lowercaseString];
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

- (void)replaceWithNewlyPairedSenseManager:(SENSenseManager*)senseManager
                                completion:(void(^)(NSError* error))completion {
    if (senseManager == nil || [senseManager  sense] == nil) {
        if (completion) completion ([self errorWithType:SENServiceDeviceErrorSenseUnavailable]);
        return;
    }
    // first, load devices info since it likely would have changed
    __weak typeof(self) weakSelf = self;
    [self loadDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil) {
            if ([[[strongSelf senseInfo] deviceId] isEqualToString:[[senseManager sense] deviceId]]) {
                [strongSelf setSenseManager:senseManager];
            } else {
                error = [strongSelf errorWithType:SENServiceDeviceErrorSenseNotMatching];
            }
        }
        if (completion) completion (error);
    }];
}

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

- (void)unpairSleepPill:(SENServiceDeviceCompletionBlock)completion {
    if ([self pillInfo] == nil) {
        if (completion) completion ( [self errorWithType:SENServiceDeviceErrorPillNotPaired] );
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice unregisterPill:[self pillInfo] completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSError* deviceError = nil;
        
        if (strongSelf) {
            if (error != nil) {
                deviceError = [strongSelf errorWithType:SENServiceDeviceErrorUnlinkPillFromAccount];
            } else {
                [strongSelf setPillInfo:nil];
            }
        }
        
        if (completion) completion (deviceError);
    }];
}

#pragma mark Unlink Sense From account

- (void)unlinkSenseFromAccount:(SENServiceDeviceCompletionBlock)completion {
    if ([self senseInfo] == nil) {
        if (completion) completion ( [self errorWithType:SENServiceDeviceErrorSenseNotPaired]);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice unregisterSense:[self senseInfo] completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSError* deviceError = nil;
        
        if (error != nil) {
            deviceError = [strongSelf errorWithType:SENServiceDeviceErrorUnlinkPillFromAccount];
        } else {
            [strongSelf setSenseInfo:nil];
            [strongSelf setSenseManager:nil];
        }
        
        if (completion) completion (deviceError);
    }];
}

#pragma mark Factory Settings

- (void)notifyFactoryRestore {
    NSString* name = SENServiceDeviceNotificationFactorySettingsRestored;
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

- (void)restoreFactorySettings:(SENServiceDeviceCompletionBlock)completion {
    if ([self senseInfo] == nil) {
        if (completion) completion ([self errorWithType:SENServiceDeviceErrorSenseUnavailable]);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    SENServiceDeviceCompletionBlock callback = completion;
    if (!callback) callback = ^(NSError* error){};
    
    void(^turnOffLedThenFail)(NSError* error) = ^(NSError* error) {
        [weakSelf setLEDState:SENSenseLEDStateOff completion:^(__unused NSError *ledError) {
            callback (error);
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
            callback (error);
            return;
        }
        
        [blockSelf setLEDState:SENSenseLEDStateActivity completion:^(NSError *error) {
            if (error != nil) {
                callback (error);
                return;
            }
            
            [SENAPIDevice removeAssociationsToSense:[self senseInfo] completion:^(__unused id data, NSError *error) {
                if (error != nil) {
                    turnOffLedThenFail(error);
                    return;
                }
                
                [[blockSelf senseManager] resetToFactoryState:^(__unused id response) {
                    [[blockSelf senseManager] disconnectFromSense];
                    [blockSelf resetDeviceStates];
                    [blockSelf notifyFactoryRestore];
                    callback (nil);
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
