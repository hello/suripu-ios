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
#import "NSString+HEMUtils.h"

#import "HEMOnboardingService.h"
#import "HEMNotificationHandler.h"

// notifications
NSString* const HEMOnboardingNotificationDidChangeSensePairing = @"HEMOnboardingNotificationDidChangeSensePairing";
NSString* const HEMOnboardingNotificationUserInfoSenseManager = @"HEMOnboardingNotificationUserInfoSenseManager";
NSString* const HEMOnboardingNotificationDidChangePillPairing = @"HEMOnboardingNotificationDidChangePillPairing";
NSString* const HEMOnboardingNotificationComplete = @"HEMOnboardingNotificationComplete";

static NSString* const HEMOnboardingErrorDomain = @"is.hello.app.onboarding";

// polling of data
static NSUInteger const HEMOnboardingMaxFeatureCheckAttempts = 5;
static CGFloat const HEMOnboardingFeatureCheckInterval = 5.0f;

static NSUInteger const HEMOnboardingMaxSensorPollAttempts = 10;
static CGFloat const HEMOnboardingSensorPollIntervals = 5.0f;
// pre-scanning for senses
static NSInteger const HEMOnboardingMaxSenseScanAttempts = 10;
// settings / preferences
static NSString* const HEMOnboardingSettingCheckpoint = @"sense.checkpoint";

static CGFloat const HEMOnboardingSenseDFUTimeout = 150.0f;
static CGFloat const HEMOnboardingSenseDFUCheckInterval = 5.0f;

@interface HEMOnboardingService()

@property (nonatomic, assign, getter=isPollingSensorData) BOOL pollingSensorData;
@property (nonatomic, assign) NSUInteger sensorPollingAttempts;
@property (nonatomic, copy)   NSArray* nearbySensesFound;
@property (nonatomic, assign) NSInteger senseScanAttempts;
@property (nonatomic, strong) SENAccount* currentAccount;
@property (nonatomic, strong) SENSenseManager* currentSenseManager;
@property (nonatomic, assign, getter=shouldStopPreScanningForSenses) BOOL stopPreScanningForSenses;
@property (nonatomic, strong) SENDFUStatus* currentDFUStatus;
@property (nonatomic, strong) NSTimer* senseDFUTimer;
@property (nonatomic, copy)   HEMOnboardingDFUHandler dfuCompletionHandler;

@property (nonatomic, strong) SENFeatures* features;
@property (nonatomic, assign) NSInteger featureCheckAttempts;

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

- (void)reset {
    [self clearAll];
    [self setCurrentAccount:nil];
    [self resetOnboardingCheckpoint];
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

- (BOOL)hasRequiredFields:(SENAccount*)tempAccount password:(NSString*)password {
    // last name is optional
    return [[[tempAccount firstName] trim] length] > 0
        && [[[tempAccount email] trim] length] > 0
        && [password length] > 0;
}

- (BOOL)isFirstNameValid:(NSString*)firstName {
    return [[firstName trim] length] > 0;
}

- (BOOL)isLastNameValid:(NSString*)lastName {
    return YES; // it's optional
}

- (BOOL)isEmailValid:(NSString*)email {
    return [[email trim] isValidEmail];
}

- (BOOL)isPasswordValid:(NSString*)password {
    return [password length] > 0;
}

- (void)createAccount:(SENAccount*)tempAccount
         withPassword:(NSString*)password
    onAccountCreation:(void(^)(SENAccount* account))accountCreatedBlock
           completion:(void(^)(SENAccount* account, NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount createAccount:tempAccount withPassword:password completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!error) {
            if (data) {
                [strongSelf setCurrentAccount:data];
                
                if (accountCreatedBlock) {
                    accountCreatedBlock(data);
                }
                
                [strongSelf authenticateUser:[tempAccount email]
                                        pass:password
                                       retry:YES
                                  completion:^(NSError *error) {
                                      if (completion) {
                                          if (!error) {
                                              [strongSelf pushDefaultPreferences];
                                          }
                                          completion (data, error);
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
        
        if (error) {
            [SENAnalytics trackError:error];
        }
        
        if (completion) {
            completion (error);
        }
    }];
}

- (void)finishSignIn {
    [SENAnalytics track:kHEMAnalyticsEventSignIn];
    [HEMNotificationHandler registerForRemoteNotificationsIfEnabled];
    [self checkFeatures];
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
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // load the service data so is readily available, if not in onboarding
        if ([strongSelf hasFinishedOnboarding]) {
            [[SENServiceDevice sharedService] loadDeviceInfo:nil];
        }
        
        [SENAnalytics track:HEMAnalyticsEventSensePaired];
        [strongSelf checkFeatures];
        
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

#pragma mark - Force OTA

- (void)checkIfSenseDFUIsRequired {
    DDLogVerbose(@"checking if sense dfu is required");
    if (![self currentDFUStatus]) {
        __weak typeof(self) weakSelf = self;
        [SENAPIDevice getOTAStatus:^(SENDFUStatus* status, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                [SENAnalytics trackError:error];
            } else {
                DDLogInfo(@"DFU state is %ld", (long)[status currentState]);
                [strongSelf setCurrentDFUStatus:status];
            }
        }];
    }
}

- (void)forceSenseToUpdateFirmware:(HEMOnboardingDFUStatusHandler)update
                        completion:(HEMOnboardingDFUHandler)completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice forceOTA:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
            completion (error);
        } else {
            [strongSelf setDfuCompletionHandler:completion];
            [strongSelf scheduleDFUTimeout];
            [strongSelf checkSenseDFUStatus:update];
        }
    }];
}

- (void)checkSenseDFUStatus:(HEMOnboardingDFUStatusHandler)update {
    if (![self senseDFUTimer]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void(^finish)(NSError* error) = ^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf cancelSenseDFUTimeout];
        
        if ([strongSelf dfuCompletionHandler]) {
            [strongSelf dfuCompletionHandler] (error);
            [strongSelf setDfuCompletionHandler:nil];
        }
        
        if (error) {
            [SENAnalytics trackError:error];
        }
    };
    
    [SENAPIDevice getOTAStatus:^(SENDFUStatus* status, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            finish (error);
        }
        
        DDLogVerbose(@"current dfu status %ld", (long)[status currentState]);
        
        switch ([status currentState]) {
            case SENDFUStateComplete: {
                finish(nil);
                break;
            }
            case SENDFUStateError: {
                NSString* reason = @"sense dfu status check returned error state";
                finish ([strongSelf errorWithCode:HEMOnboardingErrorDFUStatusError
                                           reason:reason]);
                break;
            }
            default: {
                if (update) {
                    update (status);
                }
                
                int64_t delay = (int64_t) (HEMOnboardingSenseDFUCheckInterval * NSEC_PER_SEC);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
                    [strongSelf checkSenseDFUStatus:update];
                });
                break;
            }
        }
    }];
}

- (BOOL)isDFURequiredForSense {
    return [[self currentDFUStatus] isRequired]
        || [[self currentDFUStatus] currentState] == SENDFUStateInProgress;
}

- (void)scheduleDFUTimeout {
    [self cancelSenseDFUTimeout];
    [self setSenseDFUTimer:[NSTimer scheduledTimerWithTimeInterval:HEMOnboardingSenseDFUTimeout
                                                            target:self
                                                          selector:@selector(senseDFUTimeout)
                                                          userInfo:nil
                                                           repeats:NO]];
}

- (void)cancelSenseDFUTimeout {
    if ([self senseDFUTimer]) {
        [[self senseDFUTimer] invalidate];
        [self setSenseDFUTimer:nil];
    }
}

- (void)senseDFUTimeout {
    DDLogVerbose(@"sense dfu timed out");
    if ([self dfuCompletionHandler]) {
        NSString* reason = @"dfu process timed out";
        NSError* error = [self errorWithCode:HEMOnboardingErrorDFUTimeout reason:reason];
        [self dfuCompletionHandler] (error);
    }
    [self setSenseDFUTimer:nil];
    [self setDfuCompletionHandler:nil];
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

#pragma mark - enabled features

- (void)checkFeatures {
    if (![self features]) {
        [self setFeatureCheckAttempts:1];
        __weak typeof(self) weakSelf = self;
        [SENAPIFeature getFeatures:^(SENFeatures* features, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                [SENAnalytics trackError:error];
                
                if ([strongSelf featureCheckAttempts] <= HEMOnboardingMaxFeatureCheckAttempts) {
                    int64_t delayInSecs = (int64_t) (HEMOnboardingFeatureCheckInterval * NSEC_PER_SEC);
                    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
                    dispatch_after(delay, dispatch_get_main_queue(), ^{
                        [strongSelf checkFeatures];
                    });
                }

            } else {
                [strongSelf setFeatures:features];
            }
        }];
    }
}

- (void)saveFeatures:(SENFeatures*)features {
    [features save];
    [self setFeatures:features];
}

- (BOOL)isVoiceAvailable {
    if (![self features]) {
        [self setFeatures:[SENFeatures savedFeatures]];
        DDLogVerbose(@"onboarding - features loaded from local storage %@", [self features]);
    }
    return [[self features] hasVoice];
}

@end
