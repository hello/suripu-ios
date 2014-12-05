
#import <Foundation/Foundation.h>

@class SENAccount;
@class SENSenseManager;

@interface HEMUserDataCache : NSObject

/**
 *  An accessible instance of user data for use in onboarding data collection
 *
 *  @return an instance of HEMUserDataCache
 */
+ (instancetype)sharedUserDataCache;

/**
 *  Clears all saved user data for when the cache is no longer needed
 */
+ (void)clearSharedUserDataCache;

/**
 *  Starts to poll sensor data until values are returned, at which point the
 *  polling will stop.  Clearing user data cache will also stop the polling
 */
- (void)startPollingSensorData;

@property (nonatomic, strong) SENAccount* account;
@property (nonatomic, strong) SENSenseManager* senseManager;
@property (nonatomic, assign) BOOL pollingSensor;

@end
