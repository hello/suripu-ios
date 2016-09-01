//
//  HEMSensorService.h
//  Sense
//
//  Created by Jimmy Lu on 3/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

@class SENSensor;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const kHEMSensorErrorDomain;

typedef NS_ENUM(NSInteger, HEMSensorServiceErrorCode) {
    HEMSensorServiceErrorCodePollingAlreadyStarted = -1
};

typedef void(^HEMSensorConditionslHandler)(NSArray<SENSensor*>* _Nullable sensors, NSError* _Nullable error);

@interface HEMSensorService : SENService

/**
 * @return a sorted array of cached SENSensor objects.  The sort order is the
 *         preferred order of the sensors, if displayed in a list
 */
- (nullable NSArray<SENSensor*>*)sortedCacheSensors;

/**
 * @discussion
 * Returns the current conditions for all sensors reported by Sense that is
 * paired to the account.
 *
 * @param block to call upon completion
 */
- (void)currentConditions:(HEMSensorConditionslHandler)completion;

/**
 * @description
 * If not already polling, will continuously call currentConditions: with a set
 * interval until stopped.  Upon each refresh of the conditions, the callback
 * will be called.  Be sure not to have any direct references to self in the block
 * to prevent retain cycles
 *
 * @param update: the callback to call on each refresh
 */
- (void)pollCurrentConditions:(HEMSensorConditionslHandler)update;

/**
 * @description
 * Stop the polling and remove reference to the polling update handler.
 */
- (void)stopPollingForCurrentConditions;

@end

NS_ASSUME_NONNULL_END