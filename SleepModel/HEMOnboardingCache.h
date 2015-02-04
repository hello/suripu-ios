
#import <Foundation/Foundation.h>

@class SENAccount;
@class SENSenseManager;

@interface HEMOnboardingCache : NSObject

/**
 *  An accessible instance of user data for use in onboarding data collection
 *
 *  @return an instance of HEMOnboardingCache
 */
+ (instancetype)sharedCache;

/**
 *  Clears all saved data for when the cache is no longer needed
 */
+ (void)clearCache;

/**
 *  Starts to poll sensor data until values are returned, at which point the
 *  polling will stop.  Clearing user data cache will also stop the polling
 */
- (void)startPollingSensorData;

/**
 * Begin early caching of nearby Senses found, wh
 */
- (void)preScanForSenses;

/**
 * Clear the pre scanned Senses
 */
- (void)clearPreScannedSenses;

/**
 * Check the number of paired accounts currently attached to the Sense that
 * has been set from senseManager.  Upon completion, the pairedAccountsToSense
 * property will be set.
 */
- (void)checkNumberOfPairedAccounts;

@property (nonatomic, strong) SENAccount* account;
@property (nonatomic, strong) SENSenseManager* senseManager;
@property (nonatomic, assign, readonly) BOOL pollingSensor;
@property (nonatomic, copy,   readonly) NSArray* nearbySensesFound;
@property (nonatomic, copy,   readonly) NSNumber* pairedAccountsToSense;

@end
