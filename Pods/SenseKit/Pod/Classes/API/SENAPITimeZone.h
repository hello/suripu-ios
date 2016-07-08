//
//  SENAPITimeZone.h
//  Pods
//
//  Created by Jimmy Lu on 10/29/14.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

typedef NS_ENUM(NSInteger, SENAPITimeZoneError) {
    SENAPITimeZoneErrorInvalidArgument = -1,
    SENAPITimeZoneErrorInvalidResponse = -2
};

@interface SENAPITimeZone : NSObject

/**
 * @method setCurrentTimeZone:
 *
 * @discussion
 * Sets the current TimeZone offset in milliseconds from UTC and the TimeZone
 * name as the id on the server.  This requires that he user is both authenticated
 * AND have a Sense paired to the account.  Otherwise, it will return an error
 *
 * @param completion: the block to invoke when operation is complete
 */
+ (void)setCurrentTimeZone:(SENAPIDataBlock)completion;

/**
 * @method setTimeZone:completion:
 *
 * @discussion
 * Configures the server to use the specified timeZone for sleep analysis and data.
 * This assumes the user is authenticated
 *
 * @param timeZone:   Time Zone to set
 * @param completion: the block to invoke when operation is complete
 */
+ (void)setTimeZone:(NSTimeZone*)timeZone completion:(SENAPIDataBlock)completion;

/**
 * @method getConfiguredTimeZone:
 *
 * @discussion
 * Get the configured time zone for the currently signed in user, if a time zone
 * was set correctly.  The response will return a NSTimeZone object or nil.
 *
 * @param completion: block to invoke when operation is complete
 */
+ (void)getConfiguredTimeZone:(SENAPIDataBlock)completion;

@end
