//
//  SENPeripheralManager.h
//  Pods
//
//  Created by Jimmy Lu on 6/30/16.
//
//

#import <Foundation/Foundation.h>

@class LGPeripheral;

NS_ASSUME_NONNULL_BEGIN

typedef void(^SENPeripheralReadyCallback)(BOOL ready);
typedef void(^SENPeripheralResponseCallback)(id _Nullable response, NSError* _Nullable error);

@interface SENPeripheralManager : NSObject

/**
 * @discussion
 * Some hardware needs to be fired up before you can even see if the device has
 * BLE turned on.  If it's not fired up, you must check back again in a few ms.
 * This method is a convenient way to not have to repeatedly check the state
 * yourself, but instead invoke your block to tell you if BLE is on or in a
 * different state.
 *
 * @param completion: the block to invoke when the BLE state can be queried
 *
 */
+ (void)whenReady:(SENPeripheralReadyCallback)completion;

/**
 * @return YES if ready, NO otherwise
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
 * @return YES if currently scanning for peripherls over BLE.  NO otherwise
 */
+ (BOOL)isScanning;

/**
 * Force the scan to stop, if one was started from scanForSens: or
 * scanForSenseWithTimeout:completion:
 */
+ (void)stopScan;

/**
 * @discussion
 * Retrieve LGCharacteristic objects - uuid pairs
 *
 * @param characteristicIds: a set of characteristic ids to retrieve
 * @param peripheral:        a peripheral to retrieve from
 * @param serviceUUID:       the service UUID that periphal supports
 * @param completion:        the callback to make when complete
 */
- (void)characteristicsWithIds:(NSSet*)characteristicIds
               insideServiceId:(NSString*)serviceUUID
                 forPeripheral:(LGPeripheral*)peripheral
                    completion:(SENPeripheralResponseCallback)completion;

@end

NS_ASSUME_NONNULL_END