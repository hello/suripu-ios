//
//  SENServiceHealthKit.h
//  Pods
//
//  Created by Jimmy Lu on 1/26/15.
//
//

#import "SENService.h"

typedef NS_ENUM(NSUInteger, SENServiceHealthKitError) {
    SENServiceHealthKitErrorNotAuthorized,
    SENServiceHealthKitErrorNotSupported
};

@interface SENServiceHealthKit : SENService

@property (nonatomic, assign) BOOL enableWrite;

/**
 * Obtain the shared HealthKit service, which will integrate Sense with
 * iOS 8+'s HealthKit
 */
+ (id)sharedService;

/**
 * Request authorization from the user to read/write from/in to HealthKit
 * @param completion: block to invoke when user completes denying/authorizing
 */
- (void)requestAuthorization:(void(^)(NSError* error))completion;

/**
 * @return YES if service can write sleep analysis to HealthKit, NO otherwise
 */
- (BOOL)canWriteSleepAnalysis;

/**
 * @return YES if healthKit is supported on device.  No otherwise
 */
- (BOOL)isSupported;

@end
