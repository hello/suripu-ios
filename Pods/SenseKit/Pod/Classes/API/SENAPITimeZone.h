//
//  SENAPITimeZone.h
//  Pods
//
//  Created by Jimmy Lu on 10/29/14.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

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

@end
