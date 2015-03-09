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
    SENAPIDeviceErrorInvalidParam = -1,
    SENAPIDeviceErrorUnexpectedResponse = -2
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

/**
 * Get metadata for the currently paired Sense for the signed in user
 *
 * @param completion: the block to invoke upon completion
 */
+ (void)getSenseMetaData:(SENAPIDataBlock)completion;

/**
 * Get the number of paired accounts for the specified senseId.  The response will
 * contain a NSNumber with an integer value indicating the number of paired accounts
 * for that Sense.  If an error is encountered at any point, that value is nil
 *
 * @param deviceId: the id of Sense
 * @param completion: the block to invoke upon completion.
 * @see getSenseMetadata
 */
+ (void)getNumberOfAccountsForPairedSense:(NSString*)deviceId completion:(SENAPIDataBlock)completion;

/**
 * Remove associations to Sense represented by the SENDevice object.  The object
 * must be of type SENDeviceTypeSense and contain a device id.
 *
 * The associations removed include any accounts currently paired to the specified
 * sense, pills attached to those accounts, as well as any alarms attached to those 
 * accounts.
 *
 * @param sense:      the device info object representing Sense
 * @param completion: the block to invoke upon completion.
 */
+ (void)removeAssociationsToSense:(SENDevice*)sense completion:(SENAPIDataBlock)completion;

@end
