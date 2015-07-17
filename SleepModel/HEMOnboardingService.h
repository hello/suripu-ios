//
//  HEMOnboardingService.h
//  Sense
//
//  Created by Jimmy Lu on 7/16/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "SENService.h"

typedef NS_ENUM(NSInteger, HEMOnboardingError) {
    HEMOnboardingErrorNoAccount = -1,
    HEMOnboardingErrorAccountCreationFailed = -2,
    HEMOnboardingErrorAuthenticationFailed = -3
};

@class SENSense;
@class SENAccount;
@class SENSenseManager;

@interface HEMOnboardingService : SENService

/**
 * @property pairedAccountsToSense
 *
 * @discussion
 * Set, after calling checkNumberOfPairedAccounts.  If it was set then, the method
 * is called again, it will override what was set before
 */
@property (nonatomic, copy, readonly) NSNumber* pairedAccountsToSense;
@property (nonatomic, copy, readonly) NSArray* nearbySensesFound;;
@property (nonatomic, strong, readonly) SENAccount* currentAccount;
@property (nonatomic, strong, readonly) SENSenseManager* currentSenseManager;

+ (instancetype)sharedService;

/**
 * Begin early caching of nearby Senses found, if any.  Will eventually stop if
 * not ask to stop if nothing was found
 */
- (void)preScanForSenses;
- (void)disconnectCurrentSense;
- (BOOL)foundNearyBySenses;
- (void)clearNearBySensesCache;
- (SENSense*)nearestSense;
- (void)replaceCurrentSenseManagerWith:(SENSenseManager*)manager;

/**
 * Stop the pre-scanning that may or may not have been started
 */
- (void)stopPreScanning;

/**
 *  Starts to poll sensor data until values are returned, at which point the
 *  polling will stop.  Clearing user data cache will also stop the polling.
 */
- (void)startPollingSensorData;

#pragma mark - Accounts

- (void)loadCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion;
- (void)refreshCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion;
- (void)updateCurrentAccount:(void(^)(NSError* error))completion;

/**
 * Check the number of paired accounts currently attached to the Sense that
 * has been set for the currently active sense manager, if any.  Upon completion,
 * the property pairedAccountsToSense will be set
 */
- (void)checkNumberOfPairedAccounts;

- (void)createAccountWithName:(NSString*)name
                        email:(NSString*)email
                         pass:(NSString*)password
            onAccountCreation:(void(^)(SENAccount* account))accountCreatedBlock
                   completion:(void(^)(SENAccount* account, NSError* error))completion;

- (void)clear;

@end
