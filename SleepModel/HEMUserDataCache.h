
#import <Foundation/Foundation.h>
#import <SenseKit/SENAPIAccount.h>

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
 *  Update the account of the currently authenticated user with shared data
 */
+ (void)updateAccountWithSharedUserDataWithCompletion:(void (^)(NSError*))block;

@property (nonatomic, strong) NSNumber* age;
@property (nonatomic, strong) NSNumber* heightInCentimeters;
@property (nonatomic, strong) NSNumber* weightInKilograms;
@property (nonatomic) SENAPIAccountGender gender;
@end
