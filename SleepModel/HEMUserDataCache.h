
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

@property (nonatomic, strong) NSNumber* age;

@property (nonatomic, strong) SENAccount* account;
@property (nonatomic, strong) SENSenseManager* senseManager;

@end
