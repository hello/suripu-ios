//
// HEMLocationCenter.h
// Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

typedef enum {
    HEMLocationErrorCodeNotAuthorized = -10,
    HEMLocationErrorCodeNotEnabled = -11
} HEMLocationErrorCode;

typedef BOOL(^HEMLocationSuccessBlock)(double lat, double lon, double accuracy);
typedef BOOL(^HEMLocationFailureBlock)(NSError* error);

@interface HEMLocationCenter : NSObject <CLLocationManagerDelegate>

/**
 * Allocate, if not already, a singleton instance of HEMLocationCenter and returns
 * it initlized.
 */
+ (id)sharedCenter;

/**
 * Locate the current device, returning the lat/long/accuracy to the success callback
 * passed in.  If location service is not authorized or enabled, a locationError will
 * be set upon return of the call, in which case the blocks will not be called and a
 * "token" will not be returned.  If location is enabled, it will proceed to start
 * the service and return to you a token, in which you should hold on to as a way to
 * stop location service upon deallocation, if not already stopped.
 *
 * In the callbacks, returning NO will stop the service for this particular transaction.
 * If all transactions are cleared / stopped, the service will completely stop
 *
 * @param locationError: service restriction error
 * @param success: callback when location data is available.  will call multiple times,
 *                 unless told otherwise
 * @param failure: called if location data is enabled / authorized, but failed to obtain
 *                 data
 * @return token to be used to stop the transaction / service
 */
- (NSString*)locate:(NSError**)locationError
            success:(HEMLocationSuccessBlock)success
            failure:(HEMLocationFailureBlock)failure;

/**
 * Stop location service for the particular transaction using the unique token provided
 * when locate:success:failure was called.
 *
 * @param token: token that uniquely maps to the locate:success:failure call
 */
- (void)stopLocatingFor:(NSString*)token;

@end
