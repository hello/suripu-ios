//
//  SENSenseManager.h
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENSense;
@class LGCentralManager;

typedef void(^SENSenseCompletionBlock)(id response, NSError* error);
typedef void(^SENSenseSuccessBlock)(id response);
typedef void(^SENSenseFailureBlock)(NSError* error);

typedef NS_ENUM (NSInteger, SENSenseManagerErrorCode) {
    SENSenseManagerErrorCodeNone = 0,
    SENSenseManagerErrorCodeNoDeviceSpecified = -1,
    SENSenseManagerErrorCodeInvalidArgument = -2,
    SENSenseManagerErrorCodeUnexpectedResponse = -3,
    SENSenseManagerErrorCodeTimeout = -4,
    SENSenseManagerErrorCodeDeviceAlreadyPaired = -5,
    SENSenseManagerErrorCodeInvalidCommand = -6,
    SENSenseManagerErrorCodeConnectionFailed = -7,
    SENSenseManagerErrorCodeInvalidated = -8,
    SENSenseManagerErrorCodeInternalFailure = -9,
    SENSenseManagerErrorCodeDeviceOutOfMemory = -10,
    SENSenseManagerErrorCodeDeviceDbFull = -11,
    SENSenseManagerErrorCodeDeviceNetworkError = -12
};

@interface SENSenseManager : NSObject

@property (nonatomic, strong, readonly) SENSense* sense;

/**
 * Scan for any senses that may be nearby with a default timemout
 * interval.  On completion, an array of SENSense objects are
 * returned
 * @param completion: the completion block to call when finished
 */
+ (BOOL)scanForSense:(void(^)(NSArray* senses))completion;

/**
 * Scan for any senses that may be nearby with a specified timeout
 * @param timeout: timeout in seconds
 * @param completion: the completion block to call when finished
 */
+ (BOOL)scanForSenseWithTimeout:(NSTimeInterval)timeout
                     completion:(void(^)(NSArray* senses))completion;

/**
 * Force the scan to stop, if one was started from scanForSens: or
 * scanForSenseWithTimeout:completion:
 */
+ (void)stopScan;

/**
 * Check to see if manager is currently scanning for senses
 * @return YES if scanning, NO otherwise
 */
+ (BOOL)isScanning;

/**
 * Check to see if Central is ready to go
 * @return YES if on, NO otherwise
 */
+ (BOOL)isReady;

/**
 * Determine, as best as possible, whether if manager can actually start a scan
 * based on whether BLE is supported and enabled.  If the radio is resetting or
 * in some unknown state, this will assume it's still functional and thus can scan,
 * but possibly not yet ready.
 *
 * @return YES if can scan, NO otherwise
 */
+ (BOOL)canScan;

/**
 * Initialize a manager for the specified Sense object.  You can retrieve
 * a sense object by calling scanForSense: or scanForSenseWithTimeout:completion.
 *
 * @param sense: the sense device to manage
 * @return an instance of SENSenseManager
 */
- (instancetype)initWithSense:(SENSense*)sense;

#pragma mark - Pairing

/**
 * Pair with the initialized Sense device.
 * @param success: the block to invoke upon successfully pairing with Sense
 * @param failure: the block to invoke if pairing failed for any reason
 */
- (void)pair:(SENSenseSuccessBlock)success
     failure:(SENSenseFailureBlock)failure;

/**
 * Enable / Disable pairing mode on Sense.  Disabling the paring
 * mode will simply return Sense back to normal mode.  Normally,
 * the caller should not have to disable pairing mode once paring
 * mode is enabled.  The device will do so once it has been paired.
 *
 * @param success: callback when pairing mode enabled / disabled
 * @param failure: callback if we failed to switch the mode
 */
- (void)enablePairingMode:(BOOL)enable
                  success:(SENSenseSuccessBlock)success
                  failure:(SENSenseFailureBlock)failure;

/**
 * Remove devices, other than than the currently connected device, from
 * Sense.  This will open up additional device spots to allow new devices
 * to be paired with Sense
 * 
 * @param success: callback to invoke when this has succeeded
 * @param failure: callback to invoke if an error encountered
 */
- (void)removeOtherPairedDevices:(SENSenseSuccessBlock)success
                         failure:(SENSenseFailureBlock)failure;

/**
 * Link the user account using the user's authenticated access token with
 * Sense.  Wifi must be set up with Sense to proceed.
 * @param accountAccessToken: access token of the authenticated user
 * @param success: the callback to invoke when process succeeded
 * @param failure: the callback to invoke when process failed for any reason
 */
- (void)linkAccount:(NSString*)accountAccessToken
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure;

/**
 * Tell Sense to pair with nearby Pills.  Once the pairing has completed, Sense
 * will update the user account with such information and as such will require:
 *
 *     1. wifi to have been set up
 *     2. access token of the authenticated user.
 *
 * @param accountAccessToken: access token of the authenticated user
 * @param success: the callback to invoke when process succeeded
 * @param failure: the callback to invoke when process failed for any reason
 */
- (void)pairWithPill:(NSString*)accountAccessToken
             success:(SENSenseSuccessBlock)success
             failure:(SENSenseFailureBlock)failure;

/**
 * Tell Sense to unpair with the pill, specified by the pill id.  This will prevent
 * the Pill from sending any data to Sense.
 * 
 * @param pillId:  the device id of the pill.  @see SENDevice
 * @param success: the block to invoke when this command succeeds
 * @param failure: the failure block to invoke if this fails
 */
- (void)unpairPill:(NSString*)pillId
           success:(SENSenseSuccessBlock)success
           failure:(SENSenseFailureBlock)failure;

#pragma mark - Signal Strengths / RSSI

/**
 * Get the current RSSI value for the initialized SENSense object.  The device
 * must be near as this will try to connect to the device, if not already.
 * @param success: the block to invoke when rssi value is retrieved
 * @param failure: the block to invoke if any any problems were encountered.
 */
- (void)currentRSSI:(SENSenseSuccessBlock)success failure:(SENSenseFailureBlock)failure;

#pragma mark - Connections

/**
 * Disconnect from Sense, if connected.  This will not trigger a callback to
 * observers of unexpected disconnects.
 */
- (void)disconnectFromSense;

/**
 * Observe any unexpected disconnects that may occur, which will invoke the block
 * specified.  You must pair this call with removeUnexpectedDisconnectObserver:
 * to prevent a potential leak as the blocks will be held until it is removed
 * @param block: the block to invoke when an unexpected disconnect happens
 * @return observerId: a unique identifier that maps to this block
 */
- (NSString*)observeUnexpectedDisconnect:(SENSenseFailureBlock)block;

/**
 * Remove the observer for unexpected disconnects, free-ing the block that was
 * passed in from observeUnexpectedDisconnect:
 * @param observerId: a unique identifier returned from observeUnexpectedDisconnect:
 */
- (void)removeUnexpectedDisconnectObserver:(NSString*)observerId;

#pragma mark - Wifi

/**
 * @method
 * Provide the initialized Sense device with the wifi credentials that it should
 * use to connect itself with the Sense API.
 * 
 * @param ssid:     the SSID of the WiFi
 * @param password: the password to the WiFI
 * @param success:  the block to call when the command succeeded
 * @param failure:  the block to call if the command encountered an error
 */
- (void)setWiFi:(NSString*)ssid
       password:(NSString*)password
        success:(SENSenseSuccessBlock)success
        failure:(SENSenseFailureBlock)failure;

#pragma mark - Factory Reset

/**
 * Reset Sense back to factory state, which will erase the device from Sense and
 * clear WiFi credentials that have been set, if any.
 * 
 * @param success:  the block to call when the command succeeded
 * @param failure:  the block to call if the command encountered an er
 */
- (void)resetToFactoryState:(SENSenseSuccessBlock)success
                    failure:(SENSenseFailureBlock)failure;

@end
