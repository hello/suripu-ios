//
//  HEMOnboardingService.m
//  Sense
//
//  Created by Jimmy Lu on 7/16/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <SenseKit/BLE.h>
#import <SenseKit/API.h>
#import <SenseKit/SENAccount.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENServiceDevice.h>

#import "HEMOnboardingService.h"

// polling of data
static NSUInteger const HEMOnboardingMaxSensorPollAttempts = 10;
static NSUInteger const HEMOnboardingSensorPollIntervals = 5.0f;
// pre-scanning for senses
static NSInteger const HEMOnboardingMaxSenseScanAttempts = 10;

static NSString* const HEMOnboardingErrorDomain = @"is.hello.app.onboarding";

@interface HEMOnboardingService()

@property (nonatomic, assign, getter=isPollingSensorData) BOOL pollingSensorData;
@property (nonatomic, assign) NSUInteger sensorPollingAttempts;
@property (nonatomic, copy)   NSArray* nearbySensesFound;
@property (nonatomic, assign) NSInteger senseScanAttempts;
@property (nonatomic, copy)   NSNumber* pairedAccountsToSense;
@property (nonatomic, strong) SENAccount* currentAccount;
@property (nonatomic, strong) SENSenseManager* currentSenseManager;
@property (nonatomic, assign, getter=shouldStopPreScanningForSenses) BOOL stopPreScanningForSenses;

@end

@implementation HEMOnboardingService

+ (instancetype)sharedService {
    static HEMOnboardingService* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super allocWithZone:NULL] init];
    });
    return service;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedService];
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)clear {
    [self stopPreScanning];
    [SENSenseManager stopScan]; // if one is still scanning for some reason
    [self setNearbySensesFound:nil];
    [self setPairedAccountsToSense:nil];
    [self setPollingSensorData:NO];
    [self setSensorPollingAttempts:0];
    [self setSenseScanAttempts:0];
    // leave the current sense manager in place
}

- (NSError*)errorWithCode:(HEMOnboardingError)code reason:(NSString*)reason {
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey : reason ?: @""};
    return [NSError errorWithDomain:HEMOnboardingErrorDomain
                               code:code
                           userInfo:userInfo];
}

#pragma mark - Sense

/**
 * @return the currently used sense manager.  Because onboarding views / controllers
 *         can be reused within settings, we need to make sure that we check to
 *         make sure we're using the actual sense manager that is instantiated
 */
- (SENSenseManager*)currentSenseManager {
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    SENSenseManager* manager = nil;
    if ([deviceService senseManager]) {
        manager = [deviceService senseManager];
    } else {
        manager = _currentSenseManager;
    }
    return manager;
}

- (void)replaceCurrentSenseManagerWith:(SENSenseManager*)manager {
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    if ([deviceService senseManager]) {
        [deviceService replaceWithNewlyPairedSenseManager:manager completion:nil];
    } else {
        _currentSenseManager = manager;
    }
}

- (void)stopPreScanning {
    [self setStopPreScanningForSenses:YES];
}

- (void)preScanForSenses {
    __weak typeof(self) weakSelf = self;
    [SENSenseManager whenBleStateAvailable:^(BOOL on) {
        if (on) {
            [weakSelf scanForSenses];
        } else {
            DDLogVerbose(@"pre-scanning for nearby senses skipped, ble not on");
        }
    }];
}

- (void)scanForSenses {
    if ([self shouldStopPreScanningForSenses]) {
        [self setStopPreScanningForSenses:NO];
        DDLogVerbose(@"pre-scanning stopped");
        return;
    }
    
    if ([self senseScanAttempts] >= HEMOnboardingMaxSenseScanAttempts) {
        DDLogVerbose(@"pre-scanning for senses stopped, max attempts reached");
        return;
    }
    
    if ([SENSenseManager isScanning]) {
        DDLogVerbose(@"pre-scanning skipped, already scanning");
        return;
    }
    
    [SENSenseManager stopScan]; // stop a scan if one is in progress;
    DDLogVerbose(@"pre-scanning for nearby senses");
    
    float retryInterval = 0.2f;
    __weak typeof(self) weakSelf = self;
    if (![SENSenseManager scanForSense:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"found senses %@", senses);
        if ([senses count] == 0) {
            [strongSelf performSelector:@selector(scanForSenses)
                             withObject:nil
                             afterDelay:retryInterval];
        } else {
            [strongSelf setNearbySensesFound:senses];
        }
    }]) {
        [self performSelector:@selector(preScanForSenses)
                   withObject:nil
                   afterDelay:retryInterval];
    }
}

- (SENSense*)nearestSense {
    return [[self nearbySensesFound] firstObject];
}

- (BOOL)foundNearyBySenses {
    return [[self nearbySensesFound] count] > 0;
}

- (void)disconnectCurrentSense {
    [[self currentSenseManager] disconnectFromSense];
}

- (void)clearNearBySensesCache {
    [self setNearbySensesFound:nil];
}

#pragma mark - Room Conditions

- (void)startPollingSensorData {
    if (![self isPollingSensorData]
        && [self sensorPollingAttempts] < HEMOnboardingMaxSensorPollAttempts) {
        
        [self setSensorPollingAttempts:[self sensorPollingAttempts]+1];
        [self setPollingSensorData:YES];
        
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(sensorsDidUpdate:)
                       name:SENSensorsUpdatedNotification
                     object:nil];
        
        DDLogVerbose(@"polling for sensor data during onboarding");
        [SENSensor refreshCachedSensors];
    } else {
        DDLogVerbose(@"polling stopped, attempts %ld", (long)[self sensorPollingAttempts]);
    }
}

- (void)sensorsDidUpdate:(NSNotification*)note {
    if ([self isPollingSensorData]) {
        [self setPollingSensorData:NO];
        NSArray* sensors = [SENSensor sensors];
        NSInteger sensorCount = [sensors count];
        DDLogVerbose(@"sensors returned %ld", (long)sensorCount);
        if (sensorCount == 0
            || [((SENSensor*)sensors[0]) condition] == SENConditionUnknown) {
            
            __weak typeof (self) weakSelf = self;
            int64_t delayInSec = (int64_t)(HEMOnboardingSensorPollIntervals * NSEC_PER_SEC);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSec);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [weakSelf startPollingSensorData];
            });
            
        }
    }
    // always remove observer on update since it will add observer upon next attempt
    // or simply stop polling
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:SENSensorsUpdatedNotification object:nil];
}

#pragma mark - Accounts

- (void)checkNumberOfPairedAccounts {
    NSString* deviceId = [[[self currentSenseManager] sense] deviceId];
    if ([deviceId length] > 0) {
        __weak typeof(self) weakSelf = self;
        [SENAPIDevice getNumberOfAccountsForPairedSense:deviceId completion:^(NSNumber* pairedAccounts, NSError *error) {
            DDLogVerbose(@"sense %@ has %ld account paired to it", deviceId, [pairedAccounts longValue]);
            [weakSelf setPairedAccountsToSense:pairedAccounts];
        }];
    }
}

- (void)loadCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion {
    if (![self currentAccount]) {
        [self refreshCurrentAccount:completion];
    } else {
        if (completion) {
            completion ([self currentAccount], nil);
        }
    }
}

- (void)refreshCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount getAccount:^(SENAccount* account, NSError *error) {
        [weakSelf setCurrentAccount:account];
        if (completion) {
            completion (account, error);
        }
    }];
}

- (void)updateCurrentAccount:(void(^)(NSError* error))completion {
    if ([self currentAccount]) {
        [SENAPIAccount updateAccount:[self currentAccount] completionBlock:^(id data, NSError *error) {
            if (completion) {
                completion (error);
            }
        }];
    }
}

- (void)createAccountWithName:(NSString*)name
                        email:(NSString*)email
                         pass:(NSString*)password
            onAccountCreation:(void(^)(SENAccount* account))accountCreatedBlock
                   completion:(void(^)(SENAccount* account, NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount createAccountWithName:name
                            emailAddress:email
                                password:password
                              completion:^(SENAccount* account, NSError* error) {
                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                  
                                  if (!error) {
                                      if (account) {
                                          [strongSelf setCurrentAccount:account];
                                          
                                          if (accountCreatedBlock) {
                                              accountCreatedBlock(account);
                                          }
                                          
                                          [strongSelf authenticateUser:email
                                                                  pass:password
                                                                 retry:YES
                                                            completion:^(NSError *error) {
                                                                if (completion) {
                                                                    completion (account, error);
                                                                }
                                                            }];
                                          return;
                                      }
                                  }
                                  
                                  if (completion) {
                                      completion (nil, [strongSelf errorWithCode:HEMOnboardingErrorAccountCreationFailed
                                                                          reason:[error localizedDescription]]);
                                  }
                              }];
}

- (void)authenticateUser:(NSString*)email
                    pass:(NSString*)password
                   retry:(BOOL)retry
              completion:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:email password:password callback:^(NSError *signInError) {
        NSError* error = nil;
        if (signInError) {
            if (retry) {
                DDLogVerbose(@"authentication failed, retrying once");
                [weakSelf authenticateUser:email pass:password retry:NO completion:completion];
                return;
            }
            
            error = [weakSelf errorWithCode:HEMOnboardingErrorAuthenticationFailed
                                     reason:[signInError localizedDescription]];
        }
        
        if (completion) {
            completion (error);
        }
    }];
}

@end
