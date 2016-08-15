//
//  HEMBluetoothUtils.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HEMBluetoothStateHandler)(BOOL on);

@interface HEMBluetoothUtils : NSObject

/**
 * @method
 * Determine if BLE is supported on the calling device.  stateAvailable must return YES
 * for this to report accurate response
 *
 * @see @method stateAvailable.
 *
 * @return YES if supported, NO otherwise
 */
+ (BOOL)isBleSupported;

/**
 * @method
 * Determine if Bluetooth is currently on or off.  stateAvailable must return YES
 * for this to report accurate response
 *
 * @see @method stateAvailable.
 *
 * @return YES if ON, No otherwise
 */
+ (BOOL)isBluetoothOn;

/**
 * @method
 * Determien if this util can determine the state or not.  If not, check back
 * later and it should be good to go.
 *
 * @return YES if ble state is available to be queried.  No otherwise
 */
+ (BOOL)stateAvailable;

/**
 * @discussion
 * Call this method to determine if bluetooth is on and ready for use.  This will
 * wait for the state to be known, before checking whether it's on.
 *
 * @param completion: the handler to call when state is available
 */
+ (void)whenBleStateAvailable:(HEMBluetoothStateHandler)completion;

@end
