//
//  HEMSensorService.h
//  Sense
//
//  Created by Jimmy Lu on 3/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

@class SENSensor;
@class SENSensorDataPoint;
@class SENSensorStatus;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const kHEMSensorErrorDomain;

typedef NS_ENUM(NSInteger, HEMSensorServiceErrorCode) {
    HEMSensorServiceErrorCodePollingAlreadyStarted = -1,
    HEMSensorServiceErrorCodeNoSense = -2
};

typedef NS_ENUM(NSUInteger, HEMSensorServiceScope) {
    HEMSensorServiceScopeDay = 0,
    HEMSensorServiceScopeWeek
};

typedef void(^HEMSensorDataHandler)(NSDictionary<NSString*, NSArray<SENSensorDataPoint*>*>* _Nullable data,
                                    NSError* _Nullable error);
typedef void(^HEMSensorStatusHandler)(SENSensorStatus* _Nullable status,
                                    NSError* _Nullable error);

@interface HEMSensorService : SENService

/**
 * @discussion
 * Returns the current conditions for all sensors reported by Sense that is
 * paired to the account.
 *
 * @param block to call upon completion
 */
- (void)roomStatus:(HEMSensorStatusHandler)completion;

/**
 * @discussion
 * Returns the room data for specified list of Sensors
 *
 * @param sensors: list of sensors to retrieve data for
 * @param completion: the block to call upon completion
 */
- (void)roomDataForSensors:(NSArray<SENSensor*>*)sensors
                completion:(HEMSensorDataHandler)completion;

/**
 * @description
 * If not already polling, will continuously call roomData: with a set interval 
 * until stopped.  Upon each refresh of the conditions, the callback will be called.  
 * Be sure not to have any direct references to self in the block to prevent retain 
 * cycles
 *
 * @param sensors: sensors to continually poll data for
 * @param update: the callback to call on each refresh
 */
- (void)pollRoomDataForSensors:(NSArray<SENSensor*>*)sensors update:(HEMSensorDataHandler)update;

/**
 * @description
 * Stop the polling and remove reference to the polling update handler.
 */
- (void)stopPollingForRoomData;

@end

NS_ASSUME_NONNULL_END