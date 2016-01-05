//
//  HEMOnboardingService.m
//  Sense
//
//  TODO: we should merge this with the device service or handle all device
//  interaction through SENServiceDevice or here, but not spread it across
//  both
//
//  Created by Jimmy Lu on 7/16/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <AFNetworking/AFURLResponseSerialization.h>

#import <SenseKit/BLE.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENServiceDevice.h>

#import "NSBundle+HEMUtils.h"

#import "HEMOnboardingService.h"

// notifications
NSString* const HEMOnboardingNotificationDidChangeSensePairing = @"HEMOnboardingNotificationDidChangeSensePairing";
NSString* const HEMOnboardingNotificationUserInfoSenseManager = @"HEMOnboardingNotificationUserInfoSenseManager";
NSString* const HEMOnboardingNotificationDidChangePillPairing = @"HEMOnboardingNotificationDidChangePillPairing";
NSString* const HEMOnboardingNotificationComplete = @"HEMOnboardingNotificationComplete";

static NSString* const HEMOnboardingErrorDomain = @"is.hello.app.onboarding";

// polling of data
static NSUInteger const HEMOnboardingMaxSensorPollAttempts = 10;
static NSUInteger const HEMOnboardingSensorPollIntervals = 5.0f;
// pre-scanning for senses
static NSInteger const HEMOnboardingMaxSenseScanAttempts = 10;
// settings / preferences
static NSString* const HEMOnboardingSettingCheckpoint = @"sense.checkpoint";

@interface HEMOnboardingService()

@property (nonatomic, assign, getter=isPollingSensorData) BOOL pollingSensorData;
@property (nonatomic, assign) NSUInteger sensorPollingAttempts;
@property (nonatomic, copy)   NSArray* nearbySensesFound;
@property (nonatomic, assign) NSInteger senseScanAttempts;
@property (nonatomic, strong) SENAccount* currentAccount;
@property (nonatomic, strong) SENSenseManager* currentSenseManager;
@property (nonatomic, assign, getter=shouldStopPreScanningForSenses) BOOL stopPreScanningForSenses;

@end

@implementation HEMOnboardingService

+ (instancetype)sharedService {
    static HEMOnboardingService* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super alloc] init];
    });
    return service;
}

- (void)clear {
    [self stopPreScanning];
    [SENSenseManager stopScan]; // if one is still scanning for some reason
    [self setNearbySensesFound:nil];
    [self setPollingSensorData:NO];
    [self setSensorPollingAttempts:0];
    [self setSenseScanAttempts:0];
    // leave the current sense manager in place
}

- (void)clearAll {
    [self clear];
    [self disconnectCurrentSense];
    [self setCurrentSenseManager:nil];
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
    DDLogVerbose(@"replacing current manager %@, with %@", [self currentSenseManager], manager);
    [self setCurrentSenseManager:manager];
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

- (BOOL)foundNearbySenses {
    return [[self nearbySensesFound] count] > 0;
}

- (void)disconnectCurrentSense {
    [[self currentSenseManager] disconnectFromSense];
}

- (void)clearNearbySensesCache {
    [self setNearbySensesFound:nil];
}

#pragma mark - Pairing Mode for next user

- (void)enablePairingMode:(void(^)(NSError* error))completion {
    SENSenseManager* manager = [self currentSenseManager];
    if (!manager) {
        if (completion) {
            completion ([self errorWithCode:HEMOnboardingErrorSenseNotInitialized
                                     reason:@"cannot enable pairing mode without a sense"]);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [manager enablePairingMode:YES success:^(id response) {
        [weakSelf disconnectCurrentSense];
        if (completion) {
            completion (nil);
        }
    } failure:completion];
}

#pragma mark - Room conditions / sensor data

- (void)forceSensorDataUploadFromSense:(void(^)(NSError* error))completion {
    SENSenseManager* manager = [self currentSenseManager];
    if (manager) {
        __weak typeof(self) weakSelf = self;
        [manager forceDataUpload:^(id response, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!error && ![strongSelf hasFinishedOnboarding]) {
                [strongSelf startPollingSensorData];
            }
            if (completion) {
                completion (error);
            }
        }];
    } else {
        if (completion) {
            completion ([self errorWithCode:HEMOnboardingErrorSenseNotInitialized
                                     reason:@"cannot force sensor data upload without a sense"]);
        }
    }
}

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

- (BOOL)isAuthorizedUser {
    return [SENAuthorizationService isAuthorized];
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
                                                                    if (!error) {
                                                                        [strongSelf pushDefaultPreferences];
                                                                    }
                                                                    completion (account, error);
                                                                }
                                                            }];
                                          return;
                                      }
                                  }
                                  
                                  if (completion) {
                                      NSString* localizedMessage = [self localizedMessageFromAccountError:error];
                                      completion (nil, [strongSelf errorWithCode:HEMOnboardingErrorAccountCreationFailed
                                                                          reason:localizedMessage]);
                                  }
                              }];
}

- (void)authenticateUser:(NSString*)email
                    pass:(NSString*)password
                   retry:(BOOL)retry
              completion:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:email password:password callback:^(NSError *signInError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSError* error = nil;
        if (signInError) {
            if (retry) {
                DDLogVerbose(@"authentication failed, retrying once");
                [strongSelf authenticateUser:email pass:password retry:NO completion:completion];
                return;
            }
            
            error = [strongSelf errorWithCode:HEMOnboardingErrorAuthenticationFailed
                                       reason:[self localizedMessageFromAccountError:signInError]];
        }
        
        if (completion) {
            completion (error);
        }
    }];
}

- (void)pushDefaultPreferences {
    SENPreference* audio = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio];
    [audio saveLocally];
    
    SENPreference* height = [[SENPreference alloc] initWithType:SENPreferenceTypeHeightMetric];
    [height saveLocally];
    
    SENPreference* pushCond = [[SENPreference alloc] initWithType:SENPreferenceTypePushConditions];
    [pushCond saveLocally];
    
    SENPreference* pushScore = [[SENPreference alloc] initWithType:SENPreferenceTypePushScore];
    [pushScore saveLocally];
    
    SENPreference* temp = [[SENPreference alloc] initWithType:SENPreferenceTypeTempCelcius];
    [temp saveLocally];
    
    SENPreference* time = [[SENPreference alloc] initWithType:SENPreferenceTypeTime24];
    [time saveLocally];
    
    SENPreference* weight = [[SENPreference alloc] initWithType:SENPreferenceTypeWeightMetric];
    [weight saveLocally];
    
    [SENAPIPreferences updatePreferencesWithCompletion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventWarning];
        }
    }];
}

- (NSString*)localizedMessageFromAccountError:(NSError*)error {
    NSString* alertMessage = nil;
    SENAPIAccountError errorType = [SENAPIAccount errorForAPIResponseError:error];
    
    if (errorType == SENAPIAccountErrorUnknown) {
        if ([[error domain] isEqualToString:NSURLErrorDomain]) {
            alertMessage = [error localizedDescription];
        } else {
            NSInteger statusCode = [self httpStatusCodeFromError:error];
            switch (statusCode) {
                case 401:
                    alertMessage = NSLocalizedString(@"authorization.sign-in.failed.message", nil);
                    break;
                case 409:
                    alertMessage = NSLocalizedString(@"sign-up.error.conflict", nil);
                    break;
                default:
                    alertMessage = NSLocalizedString(@"sign-up.error.generic", nil);
                    break;
            }
        }
    } else {
        alertMessage = [self accountErrorMessageForType:errorType];
    }
    
    return alertMessage;
}

- (NSInteger)httpStatusCodeFromError:(NSError*)error {
    NSHTTPURLResponse* response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    return [response statusCode];
}

- (NSString*)accountErrorMessageForType:(SENAPIAccountError)errorType {
    NSString* message = nil;
    switch (errorType) {
        case SENAPIAccountErrorPasswordTooShort:
            message = NSLocalizedString(@"sign-up.error.password-too-short", nil);
            break;
        case SENAPIAccountErrorPasswordInsecure:
            message = NSLocalizedString(@"sign-up.error.password-insecure", nil);
            break;
        case SENAPIAccountErrorNameTooShort:
            message = NSLocalizedString(@"sign-up.error.name-too-short", nil);
            break;
        case SENAPIAccountErrorNameTooLong:
            message = NSLocalizedString(@"sign-up.error.password-too-long", nil);
            break;
        case SENAPIAccountErrorEmailInvalid:
            message = NSLocalizedString(@"sign-up.error.email-invalid", nil);
            break;
        default:
            message = NSLocalizedString(@"sign-up.error.generic", nil);
            break;
    }
    return message;
}

#pragma mark - WiFi

- (void)setWiFi:(NSString*)ssid
       password:(NSString*)password
   securityType:(SENWifiEndpointSecurityType)type
         update:(void(^)(SENSenseWiFiStatus* status))update
     completion:(void(^)(NSError* error))completion {
    
    SENSenseManager* manager = [self currentSenseManager];
    if (!manager) {
        if (completion) {
            completion ([self errorWithCode:HEMOnboardingErrorSenseNotInitialized
                                     reason:@"unable to set wifi without a sense manager initialized"]);
        }
        return;
    }
    
    [manager setWiFi:ssid password:password securityType:type update:update success:^(id response) {
        if (completion) {
            completion (nil);
        }
    } failure:completion];
    
}

#pragma mark - Link Account

// TODO: we probably should clean up onboarding service and device service
// so that all device interaction happens within one of them and not both
// such that these types of interactions are more fluid (see note after linking
// account)
- (void)linkCurrentAccount:(void(^)(NSError* error))completion {
    NSString* accessToken = [SENAuthorizationService accessToken];
    SENSenseManager* manager = [self currentSenseManager];
    
    if (!accessToken) {
        if (completion) {
            completion ([self errorWithCode:HEMOnboardingErrorMissingAuthToken
                                     reason:@"cannot link account without token"]);
        }
        return;
    }
    
    if (!manager) {
        if (completion) {
            completion ([self errorWithCode:HEMOnboardingErrorSenseNotInitialized
                                     reason:@"cannot link account without a sense manager initialized"]);
        }
        return;
    }

    __weak typeof(self) weakSelf = self;
    [manager linkAccount:accessToken success:^(id response) {
        // load the service data so is readily available, if not in onboarding
        if ([weakSelf hasFinishedOnboarding]) {
            [[SENServiceDevice sharedService] loadDeviceInfo:nil];
        }
        
        if (completion) {
            completion (nil);
        }
    } failure:completion];
}

#pragma mark - Checkpoints

- (BOOL)hasFinishedOnboarding {
    HEMOnboardingCheckpoint checkpoint = [self onboardingCheckpoint];
    
    BOOL passedCheckpoints = checkpoint == HEMOnboardingCheckpointPillDone
                                || checkpoint == HEMOnboardingCheckpointSenseColorsViewed
                                || checkpoint == HEMOnboardingCheckpointSenseColorsFinished;
    // if user is signed in and checkpoint is at the start, it means user signed in
    return [self isAuthorizedUser] && (checkpoint == HEMOnboardingCheckpointStart || passedCheckpoints);
}

- (void)saveOnboardingCheckpoint:(HEMOnboardingCheckpoint)checkpoint {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setPersistentPreference:@(checkpoint) forKey:HEMOnboardingSettingCheckpoint];
}

- (HEMOnboardingCheckpoint)onboardingCheckpoint {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [[preferences persistentPreferenceForKey:HEMOnboardingSettingCheckpoint] integerValue];
}

- (void)resetOnboardingCheckpoint {
    [self saveOnboardingCheckpoint:HEMOnboardingCheckpointStart];
}

- (void)markOnboardingAsComplete {
    // if you call this method, you want to leave onboarding so make sure it's set
    [self saveOnboardingCheckpoint:HEMOnboardingCheckpointSenseColorsFinished];
    [self clearAll];
}

#pragma mark - Notifications

- (void)notify:(NSString*)notificationName {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:notificationName object:nil];
}

- (void)notifyOfSensePairingChange {
    NSString* name = HEMOnboardingNotificationDidChangeSensePairing;
    NSDictionary* userInfo = nil;
    SENSenseManager* manager = [self currentSenseManager];
    if (manager) {
        userInfo = @{HEMOnboardingNotificationUserInfoSenseManager : manager};
    }
    NSNotification* notification = [NSNotification notificationWithName:name
                                                                 object:nil
                                                               userInfo:userInfo];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center postNotification:notification];
}

- (void)notifyOfPillPairingChange {
    [self notify:HEMOnboardingNotificationDidChangePillPairing];
}

- (void)notifyOfOnboardingCompletion {
    [self notify:HEMOnboardingNotificationComplete];
}

@end
