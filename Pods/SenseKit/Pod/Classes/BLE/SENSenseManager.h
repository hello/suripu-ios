//
//  SENSenseManager.h
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SENSenseMessage.pb.h"

@class SENSense;
@class LGCentralManager;

typedef NS_ENUM(NSUInteger, SENSenseLEDState) {
    SENSenseLEDStateOff,
    SENSenseLEDStatePair,
    SENSenseLEDStateSuccess,
    SENSenseLEDStateActivity
};

typedef void(^SENSenseCompletionBlock)(id response, NSError* error);
typedef void(^SENSenseSuccessBlock)(id response);
typedef void(^SENSenseFailureBlock)(NSError* error);

typedef NS_ENUM (NSInteger, SENSenseManagerErrorCode) {
    SENSenseManagerErrorCodeNone = 0,
    /** If SENSenseManager was not properly initialized with a Sense peripheral **/
    SENSenseManagerErrorCodeNoDeviceSpecified = -1,
    /** If any methods are called without proper arguments **/
    SENSenseManagerErrorCodeInvalidArgument = -2,
    /** 
     * If either Sense returned a code this manager does not know about, or a
     * condition was encountered that was not expected
     */
    SENSenseManagerErrorCodeUnexpectedResponse = -3,
    /** 
     * If either Sense timed out on it's operation, or the manager is tired of
     * waiting and fired a timeout on it's own, based on the operation's timeout
     * parameter
     */
    SENSenseManagerErrorCodeTimeout = -4,
    /** If Sense believes the mobile device has already been paired **/
    SENSenseManagerErrorCodeSenseAlreadyPaired = -5,
    /** If some how the manager created an invalid protobuf message**/
    SENSenseManagerErrorCodeInvalidCommand = -6,
    /** If some how, while sending a message, the connection fails **/
    SENSenseManagerErrorCodeConnectionFailed = -7,
    /** If some how, while sending a message, the connection fails **/
    SENSenseManagerErrorCodeInvalidated = -8,
    /** This is a generic code returned by Sense when something fails **/
    SENSenseManagerErrorCodeSenseInternalFailure = -9,
    /** If Sense reports that it ran out of memory **/
    SENSenseManagerErrorCodeSenseOutOfMemory = -10,
    /** If Sense's device whitelist is full, meaning it cannot pair anymore **/
    SENSenseManagerErrorCodeSenseDbFull = -11,
    /** If Sense tried to communicate with the cloud, but fail due to network **/
    SENSenseManagerErrorCodeSenseNetworkError = -12,
    /** 
     * If trying to set WiFi credentials and Sense reports back that the endpoint
     * is not in range for Sense to connect to.
     */
    SENSenseManagerErrorCodeWifiNotInRange = -13,
    /**
     * If trying to set WiFi credentials and Sense reports back that it cannot
     * connect to the network
     */
    SENSenseManagerErrorCodeWLANConnection = -14,
    /**
     * If trying to set WiFi credentials and Sense can't obtain an IP
     */
    SENSenseManagerErrorCodeFailToObtainIP = -15,
    /**
     * Error code returned from an instance of SENSenseManager if an unexpected
     * disconnect occurred while connected to Sense.
     */
    SENSenseManagerErrorCodeUnexpectedDisconnect = -16,
    /**
     * If Sense returned that it encountered an internal data error
     */
    SENSenseManagerErrorCodeCorruptTransmission = -17
};

typedef NS_ENUM(NSInteger, SENWiFiConnectionState) {
    SENWiFiConnectionStateUnknown = -1,
    SENWiFiConnectionStateConnected = 0,
    SENWiFiConnectionStateConnecting = 1,
    SENWifiConnectionStateDisconnected = 2,
    SENWiFiConnectionStateNoInternet = 3
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
 * @method whenBleStateAvailable:
 *
 * @discussion
 * Some hardware needs to be fired up before you can even see if the device has
 * BLE turned on.  If it's not fired up, you must check back again in a few ms.  
 * This method is a convenient way to not have to repeatedly check the state 
 * yourself, but instead invoke your block to tell you if BLE is on or in a 
 * different state.
 *
 * @param block: the block to invoke when the BLE state can be queried
 *
 */
+ (void)whenBleStateAvailable:(void(^)(BOOL on))block;

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

/**
 * @return YES if device is connected to Sense, NO otherwise
 */
- (BOOL)isConnected;

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
 * Determine if the WEP network key is valid / works with Sense
 * @return YES if it should work, NO otherwise
 */
+ (BOOL)isWepKeyValid:(NSString*)key;

/**
 * @method
 * Provide the initialized Sense device with the wifi credentials that it should
 * use to connect itself with the Sense API.
 * 
 * @param ssid:         the SSID of the WiFi
 * @param password:     the password to the WiFI
 * @param securityType: the supported WiFi security type
 * @param success:      the block to call when the command succeeded
 * @param failure:      the block to call if the command encountered an error
 */
- (void)setWiFi:(NSString*)ssid
       password:(NSString*)password
   securityType:(SENWifiEndpointSecurityType)securityType
        success:(SENSenseSuccessBlock)success
        failure:(SENSenseFailureBlock)failure;

/**
 * @method getWiFi:
 * 
 * @discussion:
 * Get the configured wifi ssid and state, if set, from Sense
 *
 * @param success: the block to invoke when it successfully retrieved the information
 * @param failure: the block to invoke when it failed to retrieve the info
 */
- (void)getConfiguredWiFi:(void(^)(NSString* ssid, SENWiFiConnectionState state))success
                  failure:(SENSenseFailureBlock)failure;

/**
 * Scan for WiFi networks that Sense can see.  It may take multiple scans to see
 * all nearby networks.  1 scan typically returns a good set, but missing some, but
 * 2 usually returns a full set.  3 would probably be max needed.
 *
 * @param success:  the block to call when the command succeeded
 * @param failure:  the block to call if the command encountered an error
 */
- (void)scanForWifiNetworks:(SENSenseSuccessBlock)success
                    failure:(SENSenseFailureBlock)failure;

#pragma mark - LED

/**
 * Set the LED state on Sense
 *
 * @param state:      the state in which the LED on Sense should be
 * @param completion: block to invoke when led has been set successfully or not
 */
- (void)setLED:(SENSenseLEDState)state
    completion:(SENSenseCompletionBlock)completion;

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

#pragma mark - Data

/**
 * Force sensor data to be uploaded immediately rather than have Sense upload the
 * data at the next set interval
 *
 * @param completion: the block to invoke when this is done
 */
- (void)forceDataUpload:(SENSenseCompletionBlock)completion;

@end
