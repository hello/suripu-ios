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
 */
+ (void)setCurrentTimeZone:(SENAPIDataBlock)completion;

@end
