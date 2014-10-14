//
//  HEMBluetoothUtils.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end
