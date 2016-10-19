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
@class SENSenseVoiceInfo;

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

#pragma mark - Swap

/**
 * @discussion
 * Issue an intent to swap currently connected Sense for the Sense specified by
 * the device id.  The data returned to the completion block will contain a
 * SENUpgradeStatus object, if a valid response was returned.
 * 
 * @param deviceId: the device id of the new Sense to swap to
 * @param completion: the block to call when intent has been issued
 */
+ (void)issueIntentToSwapWithDeviceId:(NSString*)deviceId completion:(nullable SENAPIDataBlock)completion;

#pragma mark - Voice

/**
 * @discussion
 * Update voice metadata / settings for Sense.  Only applies to specific device
 * hardware versions
 *
 * @param voiceInfo: the updated voice info object to be updated
 * @param senseId: the identifier of Sense to update the voice metadata for
 * @param copletion: the block to call when request is completed
 */
+ (void)updateVoiceInfo:(SENSenseVoiceInfo*)voiceInfo
             forSenseId:(NSString*)senseId
             completion:(SENAPIDataBlock)completion;

/**
 * @discussion
 * Get voice metadata / settings for Sense.  Only applies to specific device
 * hardware versions
 *
 * @param senseId: the identifier of Sense to get the voice metadata for
 * @param copletion: the block to call when request is completed
 */
+ (void)getVoiceInfoForSenseId:(NSString*)senseId completion:(SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END