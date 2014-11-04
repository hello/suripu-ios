//
//  HEMDeviceCenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/1/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENDevice;
@class SENSenseManager;

typedef NS_ENUM(NSInteger, HEMDeviceCenterError) {
    HEMDeviceCenterErrorSenseUnavailable = -1,
    HEMDeviceCenterErrorBLEUnavailable = -2,
    HEMDeviceCenterErrorInProgress = -3,
    HEMDeviceCenterErrorSenseNotPaired = -4,
    HEMDeviceCenterErrorPillNotPaired = -5,
    HEMDeviceCenterErrorUnpairPillFromSense = -6,
    HEMDeviceCenterErrorUnlinkPillFromAccount = -7,
    HEMDeviceCenterErrorUnlinkSenseFromAccount = -8
};

typedef void(^HEMDeviceCompletionBlock)(NSError* error);

extern NSString* const kHEMDeviceNotificationFactorySettingsRestored;

@interface HEMDeviceCenter : NSObject

/**
 * @property pillInfo: the device information for the Sleep Pill
 */
@property (nonatomic, strong, readonly) SENDevice* pillInfo;

/**
 * @property pillInfo: the device information for the Sense
 */
@property (nonatomic, strong, readonly) SENDevice* senseInfo;

/**
 * @property senseManager: the manager for the paired Sense that was found.  You
 *                         should only use this outside of the center if it's a
 *                         one off operation that does not require any interaction
 *                         with the API.
 *
 * @see loadDeviceInfo:
 * @see scanForPairedSense:
 */
@property (nonatomic, strong, readonly) SENSenseManager* senseManager;

/**
 * @property loadingInfo: flag that indicates whether or not device information
 *                        is still being loaded
 */
@property (nonatomic, assign, readonly, getter=isLoadingInfo) BOOL loadingInfo;

/**
 * @property infoLoaded: flag that indicates whether or not device information
 *                       has been loaded
 * 
 * @discussion
 * If this flag returns YES and pillInfo or senseInfo is nil, then that signifies
 * that such device has not yet been paired
 *
 * @see @property pillInfo
 * @see @property senseInfo
 */
@property (nonatomic, assign, readonly, getter=isInfoLoaded) BOOL infoLoaded;

+ (instancetype)sharedCenter;

/**
 * @method clearCache:
 *
 * @discussion
 * Clear the cache of device information and state of the center.  You should
 * only do this if switching users or resetting back to factory.
 */
- (void)clearCache;

/**
 * @method loadDeviceInfo
 *
 * @discussion
 * Load device information, populating both pillInfo and senseInfo on successful
 * completion.
 *
 * @param completion: the block to invoke when complete
 *
 * @see @property pillInfo
 * @see @property senseInfo
 */
- (void)loadDeviceInfo:(HEMDeviceCompletionBlock)completion;

/**
 * @method scanForPairedSense
 *
 * @discussion
 * scan for Sense that is paired / linked to the user's account.  If device info
 * has not been loaded, it will attempt to request that information before starting
 * the scan.
 *
 * @param completion: the block to invoke when complete
 *
 * @see @property senseInfo
 * @see @method stopSenseOperations
 */
- (void)scanForPairedSense:(HEMDeviceCompletionBlock)completion;

/**
 * @method putSenseIntoPairingMode
 *
 * @discussion
 * Put sense in to pairing mode.  If sense is already in pairing mode, this operation
 * will essentially do nothing but connect to Sense itself.
 * 
 * @param completion: the block to invoke when complete
 *
 * @see @method stopSenseOperations
 */
- (void)putSenseIntoPairingMode:(HEMDeviceCompletionBlock)completion;

/**
 * @method currentSenseRSSI
 *
 * @discussion
 * Grab the current RSSI value from Sense, if Sense is currently available and
 * close enough for the operation to succeed.
 *
 * @param completion: the completion block to invoke when done
 *
 *  * @see @method stopSenseOperations
 */
- (void)currentSenseRSSI:(void(^)(NSNumber* rssi, NSError* error))completion;

/**
 * @method stopScanning
 *
 * @discussion
 * If Sense is currently scanning, it will stop scanning for devices
 */
- (void)stopScanning;

/*
 * @method pairedSenseAvailable
 *
 * @discussion
 * Determine if a paired / linked Sense is currently available for use.  This suggests
 * that the device has been found / scanned and currently ready to take on operations
 *
 * @return YES if available, NO if never scanned for or simply not available.
 */
- (BOOL)pairedSenseAvailable;

/**
 * @method unpairSleepPill
 *
 * @discussion
 * Unpair the sleep pill that is currently linked to the signed in user's account,
 * identified by pillInfo.  If a Sleep Pill is not currently linked, completion
 * block will be immediately called with an error.
 *
 * @property completion: the block to invoke when done
 * @see @property pillInfo
 */
- (void)unpairSleepPill:(HEMDeviceCompletionBlock)completion;

/**
 * @method restoreFactorySettings:
 *
 * @discussion
 * Restore factory settings for the Sense system, which includes Sense as well
 * as the Sleep Pill.  This will do the following:
 *
 *     1. remove bond between this device and Sense
 *     2. clear WiFi credentials set, which will disconnect Sense from network
 *     3. Unpair / unlink Sleep Pill, if paired, from user's account
 *     4. Unpair / unlink Sense from user's account
 *
 * Upon completion, if no error is encountered, a notification with the name:
 * kHEMDeviceNotificationFactorySettingsRestored will be posted.  Act accordingly
 *
 * Please note that if Sense is not currently cached, this will assume Sense has
 * already been reset, disconnected and cleared.  Be sure to only call this method
 * once Sense is cached / scanned.
 *
 * User will still need to go in to Settings App to "Forget This Device".
 *
 * @property completion: the block to invoke when done
 */
- (void)restoreFactorySettings:(HEMDeviceCompletionBlock)completion;

/**
 * @method getConfiguredWiFiSSID
 * 
 * @discussion
 * This is just a wrapper around SENSenseManager's getConfiguredWifi method,
 * but will ensure a paired sense is detected before proceeding
 */
- (void)getConfiguredWiFiSSID:(void(^)(NSString* ssid, NSError* error))completion;

@end
