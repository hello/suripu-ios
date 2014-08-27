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

typedef enum {
    SENSenseManagerErrorCodeNoDeviceSpecified,
    SENSenseManagerErrorCodeNoInvalidArgument,
    SENSenseManagerErrorCodeUnexpectedResponse
} SENSenseManagerErrorCode;

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
 * Initialize a manager for the specified Sense object.  You can retrieve
 * a sense object by calling scanForSense: or scanForSenseWithTimeout:completion.
 *
 * @param sense: the sense device to manage
 * @return an instance of SENSenseManager
 */
- (instancetype)initWithSense:(SENSense*)sense;

#pragma mark - Paring

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

- (void)removePairedUser:(SENSenseCompletionBlock)completion;

#pragma mark - Time

- (void)setTime:(SENSenseCompletionBlock)completion;
- (void)getTime:(SENSenseCompletionBlock)completion;

#pragma mark - Wifi

- (void)setWifiEndPoint:(SENSenseCompletionBlock)completion;
- (void)getWifiEndPoint:(SENSenseCompletionBlock)completion;
- (void)scanForWifi:(SENSenseCompletionBlock)completion;
- (void)stopWifiScan:(SENSenseCompletionBlock)completion;

#pragma mark - Alarms

- (void)setAlarms:(SENSenseCompletionBlock)completion;
- (void)getAlarms:(SENSenseCompletionBlock)completion;

@end
