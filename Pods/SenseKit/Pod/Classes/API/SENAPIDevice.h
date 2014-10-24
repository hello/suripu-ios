//
//  SENAPIDevice.h
//  Pods
//
//  Created by Jimmy Lu on 9/19/14.
//
//

#import <Foundation/Foundation.h>

#import "SENAPIClient.h"

typedef NS_ENUM(NSInteger, SENAPIDeviceError) {
    SENAPIDeviceErrorInvalidParam = -1
};

@class SENDevice;

@interface SENAPIDevice : NSObject

/**
 * Get devices that have been paired to the authenticated user's account.  The
 * list of devices can be of varying types and states.
 *
 * @param completion: the completion block to invoke when request returns
 */
+ (void)getPairedDevices:(SENAPIDataBlock)completion;

/**
 * Unregister the pill from the currently signed in account (must be authorized).
 *
 * @param device: the pill to unregister
 * @param completion: the completion block to invoke when done
 */
+ (void)unregisterPill:(SENDevice*)device completion:(SENAPIDataBlock)completion;

/**
 * Unregister Sense from the currently signed in account (must be authorized).
 *
 * @param device: the sense to unregister
 * @param completion: the completion block to invoke when done
 */
+ (void)unregisterSense:(SENDevice*)device completion:(SENAPIDataBlock)completion;

@end
