//
//  SENAPIDevice.h
//  Pods
//
//  Created by Jimmy Lu on 9/19/14.
//
//

#import <Foundation/Foundation.h>

#import "SENAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SENAPIDeviceError) {
    SENAPIDeviceErrorInvalidParam = -1
};

@class SENPillMetadata;
@class SENSenseMetadata;

@interface SENAPIDevice : NSObject

/**
 * Get devices that have been paired to the authenticated user's account.  The
 * list of devices can be of varying types and states.
 *
 * @param completion: the completion block to invoke when request returns
 */
+ (void)getPairedDevices:(SENAPIDataBlock)completion;

/**
 * Get pairing information for the currently paired Sense for the signed in user
 *
 * @param completion: the block to invoke upon completion
 */
+ (void)getPairingInfo:(SENAPIDataBlock)completion;

/**
 * Unregister the pill from the currently signed in account (must be authorized).
 *
 * @param pillMetadata: the metadata for the pill to unregister
 * @param completion: the completion block to invoke when done
 */
+ (void)unregisterPill:(SENPillMetadata*)pillMetadata
            completion:(SENAPIDataBlock)completion;

/**
 * Unregister Sense from the currently signed in account (must be authorized).
 *
 * @param senseMetadata: the metadata for the sense to unregister
 * @param completion: the completion block to invoke when done
 */
+ (void)unregisterSense:(SENSenseMetadata*)senseMetadata
             completion:(SENAPIDataBlock)completion;

/**
 * Remove associations to Sense represented by the SENSenseMetadata object.
 *
 * The associations removed include any accounts currently paired to the specified
 * sense, pills attached to those accounts, as well as any alarms attached to those 
 * accounts.
 *
 * @param senseMetadata: the sense metadata object representing Sense
 * @param completion:    the block to invoke upon completion.
 */
+ (void)removeAssociationsToSense:(SENSenseMetadata*)senseMetadata
                       completion:(SENAPIDataBlock)completion;

#pragma mark - OTA

/**
 * @discussion
 * Get the current OTA status for the paired Sense
 *
 * @param completion: the block to call when response is returned
 */
+ (void)getOTAStatus:(SENAPIDataBlock)completion;

/**
 * @discussion
 * Force an OTA (DFU) for the currently paired Sense
 *
 * @param completion: the block to call when response is returned
 */
+ (void)forceOTA:(nullable SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END