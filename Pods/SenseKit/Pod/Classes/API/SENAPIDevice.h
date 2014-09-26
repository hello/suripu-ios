//
//  SENAPIDevice.h
//  Pods
//
//  Created by Jimmy Lu on 9/19/14.
//
//

#import <Foundation/Foundation.h>

#import "SENAPIClient.h"

@interface SENAPIDevice : NSObject

/**
 * Get devices that have been paired to the authenticated user's account.  The
 * list of devices can be of varying types and states.
 *
 * @param completion: the completion block to invoke when request returns
 */
+ (void)getPairedDevices:(SENAPIDataBlock)completion;

@end
