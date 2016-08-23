//
//  HEMOnboardingService.h
//  Sense
//
//  Created by Jimmy Lu on 7/16/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENService.h>
#import <SenseKit/SENSenseMessage.pb.h>

NS_ASSUME_NONNULL_BEGIN

@class SENSenseWiFiStatus;
@class SENDFUStatus;

extern NSString* const HEMOnboardingNotificationComplete;
extern NSString* const HEMOnboardingNotificationDidChangeSensePairing;
extern NSString* const HEMOnboardingNotificationUserInfoSenseManager;
extern NSString* const HEMOnboardingNotificationDidChangePillPairing;
extern NSString* const HEMOnboardingErrorDomain;

typedef NS_ENUM(NSInteger, HEMOnboardingError) {
    HEMOnboardingErrorNoAccount = -1,
    HEMOnboardingErrorAccountCreationFailed = -2,
    HEMOnboardingErrorAuthenticationFailed = -3,
    HEMOnboardingErrorSenseNotInitialized = -4,
    HEMOnboardingErrorMissingAuthToken = -5,
    HEMOnboardingErrorDFUTimeout = -6,
    HEMOnboardingErrorDFUStatusError = -7,
    HEMOnboardingErrorBLENotReady = -8,
    HEMOnboardingErrorNoSenseFound = -9,
    HEMOnboardingErrorScanTimeout = -10,
    HEMOnboardingErrorSenseDisconnected = -11,
    HEMOnboardingErrorFailedToLoadPairingInfo = -12,
    HEMOnboardingErrorNotAuthorized = -13
};

/**
 * Checkpoints to be saved when progressing through the onboarding flow so that
 * user can resume from where user left off.  It is important that '...Start'
 * start at 0 as it is the default value returned when grabbing it from storage
 * if a checkpoint has not yet been saved
 */
typedef NS_ENUM(NSUInteger, HEMOnboardingCheckpoint) {
    HEMOnboardingCheckpointStart = 0,
    HEMOnboardingCheckpointAccountCreated = 1,
    HEMOnboardingCheckpointAccountDone = 2,
    HEMOnboardingCheckpointSenseDone = 3,
    
    HEMOnboardingCheckpointPillDone NS_ENUM_DEPRECATED_IOS(7_0, 9_0, "No longer set as of 1.2.0") = 4,
    HEMOnboardingCheckpointSenseColorsViewed NS_ENUM_DEPRECATED_IOS(8_0, 9_0, "No longer set as of 1.2.0") = 5,
    
    HEMOnboardingCheckpointPillFinished = 6,
    HEMOnboardingCheckpointSenseColorsFinished = 7
};

typedef void(^HEMOnboardingDFUHandler)(NSError* _Nullable error);
typedef void(^HEMOnboardingErrorHandler)(NSError* _Nullable error);
typedef void(^HEMOnboardingWiFiHandler)(NSString* _Nullable ssid, BOOL connected, NSError* _Nullable error);
typedef void(^HEMOnboardingDFUStatusHandler)(SENDFUStatus* _Nullable status);

@class SENSense;
@class SENAccount;
@class SENSenseManager;

@interface HEMOnboardingService : SENService

@property (nonatomic, copy,   readonly) NSArray* nearbySensesFound;
@property (nonatomic, strong, readonly) SENAccount* currentAccount;
@property (nonatomic, strong, readonly) SENSenseManager* currentSenseManager;

+ (instancetype)sharedService;

/**
 * Begin early caching of nearby Senses found, if any.  Will eventually stop if
 * not ask to stop if nothing was found
 */
- (void)preScanForSenses;

/**
 * @method disconnectCurrentSense
 * 
 * @discussion
 * Disconnect the currently connected sense
 */
- (void)disconnectCurrentSense;

/**
 * @method foundNearyBySenses
 *
 * @discussion
 * Convenience method to determine if neary by senses have been found.  If found,
 * @property nearbySensesFound is filled.
 *
 */
- (BOOL)foundNearbySenses;

/**
 * @method clearNearBySensesCache
 *
 * @discussion
 * Clear the list of near by senses.  Call this after using the cache to remove
 * unused memory.  Calling @method clear or @method markOnboardingAsComplete will
 * also clear the cache
 */
- (void)clearNearbySensesCache;

/**
 * @method nearestSense
 *
 * @discussion
 * Requires a call to @method preScanForSenses
 *
 * @return return the nearest sense that was found in the cache, if any were found
 */
- (SENSense*)nearestSense;

/**
 * @discussion
 * Call this method to make the service use this specified manager for BLE operations.
 *
 * @param manager: sense manager to use, or nil to clear it out
 */
- (void)useSenseManager:(SENSenseManager*)manager;

/**
 * Stop the pre-scanning that may or may not have been started
 */
- (void)stopPreScanning;

/**
 * @method enablePairingMode:
 *
 * @discussion
 * Enable pairing mode on the currently managed sense
 *
 * @param completion: the block to invoke upon completion
 */
- (void)enablePairingMode:(void(^)(NSError* error))completion;

/**
 * @method forceSensorDataUploadFromSense:
 *
 * @discussion
 * Force Sense to start uploading sensor data immediately, rather than waiting
 * for the internal clock to fire the upload.  This requires that senseManager
 * has been initialized
 * 
 * @param completion: the block to invoke upon completion
 */
- (void)forceSensorDataUploadFromSense:(void(^)(NSError* error))completion;

- (void)rescanForNearbySenseNotMatching:(NSSet<NSString*>*)deviceIdsToFilter
                             completion:(HEMOnboardingErrorHandler)completion;
- (void)rescanForNearbySense:(HEMOnboardingErrorHandler)completion;
- (void)pairWithCurrentSenseWithLEDOn:(BOOL)turnOnLEDs
                           completion:(HEMOnboardingErrorHandler)completion;
- (void)checkIfCurrentSenseHasWiFi:(HEMOnboardingWiFiHandler)completion;
- (void)setTimeZone:(HEMOnboardingErrorHandler)completion;
- (void)stopObservingDisconnectsIfNeeded;
- (void)ensurePairedSenseIsReady:(HEMOnboardingErrorHandler)completion;

#pragma mark - Pill

- (void)pairPill:(HEMOnboardingErrorHandler)completion;

#pragma mark - Accounts

- (BOOL)isAuthorizedUser;

/**
 * @method linkCurrentAccount:
 *
 * @discussion
 * Link the currently signed in user's account with Sense
 *
 * @param completion: the block to invoke upon completion
 */
- (void)linkCurrentAccount:(void(^)(NSError* error))completion;

/**
 * @method loadCurrentAccount:
 *
 * @discussion
 * Load the currently authenticated user's account information in to the cache
 * so information can be updated upon a call to @method updateCurrentAccount:. 
 * If the account has already been loaded (cache is set), this method will simply
 * call back the completion block
 *
 * @param completion: the block to invoke if the account has be loaded.
 */
- (void)loadCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion;

/**
 * @method refreshCurrentAccount:
 *
 * @discussion
 * Similar to @method loadCurrentAccount:, this method will load the current
 * account.  This will, however, override the current account regardless of whether
 * the cache already exists or not
 *
 * @param completion: the block to invoke if the account has be loaded.
 */
- (void)refreshCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion;

/**
 * @method updateCurrentAccount:
 *
 * @discussion
 * Similar to @method loadCurrentAccount:, this method will load the current
 * account.  This will, however, override the current account regardless of whether
 * the cache already exists or not
 *
 * @param completion: the block to invoke if the account has be loaded.
 */
- (void)updateCurrentAccount:(void(^)(NSError* error))completion;

/**
 * @method createAccount:withPassword:onAccountCreation:completion:
 *
 * @discussion
 * Create a new account with the required pieces of information, calling back once
 * the account has been created and then again upon total completion
 *
 * @param tempAccount:         temp account with name and email set
 * @param password:            the password to be used for the account
 * @param accountCreatedBlock: block to call upon account creation, but before the
 *                             account is authorized for use
 * @param completion:          the block to invoke when all is done
 */
- (void)createAccount:(SENAccount*)tempAccount
         withPassword:(NSString*)password
    onAccountCreation:(void(^)(SENAccount* account))accountCreatedBlock
           completion:(void(^)(SENAccount* account, NSError* error))completion;

/**
 * @method authenticateUser:pass:retry:completion:
 *
 * @discussion
 * Authenticate the user with the specified email and password with an optional
 * flag to retry upon failure.  The retry will only happen once
 *
 * @param email:      the email of the account
 * @param password:   the password of the account
 * @param retry:      YES to retry upon the first failure, NO otherwise
 * @param completion: block to invoke upon completion
 */
- (void)authenticateUser:(NSString*)email
                    pass:(NSString*)password
                   retry:(BOOL)retry
              completion:(void(^)(NSError* error))completion;

/**
 * @discussion
 * Should call method upon successfully authenticating the user
 */
- (void)finishSignIn;

/**
 * @method localizedMessageFromAccountError:
 *
 * @discussion
 * Convenience method to translate the error that is returned from any account
 * activity in to a localized message that can be presented to the user
 * 
 * @param error: the error of encountered during account actions
 * @return       localized message translated from the error
 */
- (NSString*)localizedMessageFromAccountError:(NSError*)error;

/**
 * @discussion
 * Convenience method to retrieve the http status code from the NSError
 *
 * @return http status code if available
 */
- (NSInteger)httpStatusCodeFromError:(NSError*)error;

#pragma mark - WiFi

/**
 * @method setWiFi:password:securityType:completion
 *
 * @discussion
 * Sets the WiFi credentials on Sense, if a sense manager has been initialized.
 * Upon setting the WiFi credentials successfully, the ssid will be saved for later
 * use.
 *
 * @param ssid:       the ssid of the WiFi to set
 * @param password:   the password of the WiFi
 * @param type:       the security type of the WiFi
 * @param update:     block to invoke when Sense reports connection status
 * @param completion: block to invoke when done
 */
- (void)setWiFi:(NSString*)ssid
       password:(NSString*)password
   securityType:(SENWifiEndpointSecurityType)type
         update:(void(^)(SENSenseWiFiStatus* status))update
     completion:(void(^)(NSError* error))completion;


#pragma mark - Checkpoints

/**
 * @return YES if onboarding has finished, NO otherwise
 */
- (BOOL)hasFinishedOnboarding;

/**
 * Save the onboarding checkpoint so that when user comes back, user can resume
 * from where user left off.
 *
 * @param checkpoint: the checkpoint from which the user has hit
 */
- (void)saveOnboardingCheckpoint:(HEMOnboardingCheckpoint)checkpoint;

/**
 * Determine the current checkpoint at which the user last left off in the onboarding
 * flow, based on when it was saved.
 *
 * @return last checkpoint saved
 */
- (HEMOnboardingCheckpoint)onboardingCheckpoint;

/**
 * Clear checkpoints by resetting it to the beginning
 */
- (void)resetOnboardingCheckpoint;

/**
 * @method clear
 * 
 * @discussion
 * Clears the current cache, minus the sense manager
 */
- (void)clear;

/**
 * @method clearAll
 *
 * @discussion
 * Clears the current cache, disconnects from sense, and clears the sense manager
 *
 * @see clear
 */
- (void)clearAll;

/**
 * @discussion
 * Resets the shared instance to be reuse, if user signs out and starts onboarding
 * again.  should be called upon sign out
 */
- (void)reset;

/**
 * @method markOnboardingAsComplete:
 *
 * @discussion
 * Mark onboarding as complete, which will set the appropriate checkpoint and clear
 * out any cached data that is no longer needed.  This does NOT notify the app of
 * the completion of the flow.  This should be done separately by calling
 * notifyOfOnboardingCompletion:
 */
- (void)markOnboardingAsComplete;

/**
 * @method notifyOfSensePairingChange
 *
 * @discussion
 * Convenience method to post a notification about a Sense pairing change
 */
- (void)notifyOfSensePairingChange;

/**
 * @method notifyOfSensePairingChange
 *
 * @discussion
 * Convenience method to post a notification about a Sleep Pill pairing change
 */
- (void)notifyOfPillPairingChange;

/**
 * @method notifyOfOnboardingCompletion
 *
 * @discussion
 * Signal to the rest of the application that onboarding has completed and the
 * flow can be dismissed
 */
- (void)notifyOfOnboardingCompletion;

/**
 * @param tempAccount: the temp account to be created with properties filled in
 * @param password: the password for the account
 * @return YES if the parameters meets the required fields requirements
 */
- (BOOL)hasRequiredFields:(SENAccount*)tempAccount password:(nullable NSString*)password;

- (BOOL)isFirstNameValid:(nullable NSString*)firstName;
- (BOOL)isLastNameValid:(nullable NSString*)lastName;
- (BOOL)isEmailValid:(nullable NSString*)email;
- (BOOL)isPasswordValid:(nullable NSString*)password;

#pragma mark - LEDs

- (void)spinTheLEDs:(HEMOnboardingErrorHandler)completion;
- (void)resetLED:(HEMOnboardingErrorHandler)completion;

#pragma mark - OTA

- (void)checkIfSenseDFUIsRequired;
- (BOOL)isDFURequiredForSense;
- (void)forceSenseToUpdateFirmware:(HEMOnboardingDFUStatusHandler)update
                        completion:(HEMOnboardingDFUHandler)completion;

#pragma mark - Features

- (void)checkFeatures;
- (BOOL)isVoiceAvailable;

@end

NS_ASSUME_NONNULL_END
