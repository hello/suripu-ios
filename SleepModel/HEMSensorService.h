//
//  HEMSensorService.h
//  Sense
//
//  Created by Jimmy Lu on 3/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"
#import "SENSensor.h"

@class SENSensorStatus;
@class SENSensorDataCollection;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const kHEMSensorErrorDomain;
extern NSString* const kHEMSensorNotifyStatusChanged;
extern NSString* const kHEMSensorNotifyStatusKey;

typedef NS_ENUM(NSInteger, HEMSensorServiceErrorCode) {
    HEMSensorServiceErrorCodePollingAlreadyStarted = -1,
    HEMSensorServiceErrorCodeNoSense = -2
};

typedef NS_ENUM(NSUInteger, HEMSensorServiceScope) {
    HEMSensorServiceScopeDay = 0,
    HEMSensorServiceScopeWeek,
    HEMSensorServiceScopeLast3H
};

typedef void(^HEMSensorDataHandler)(SENSensorDataCollection* data, NSError* _Nullable error);
typedef void(^HEMSensorStatusHandler)(SENSensorStatus* _Nullable status, NSError* _Nullable error);
typedef void(^HEMSensorPollHandler)(HEMSensorServiceScope scope,
                                    SENSensorStatus* _Nullable status,
                                    SENSensorDataCollection* _Nullable data,
                                    NSError* _Nullable error);

@interface HEMSensorService : SENService

/**
 * @discussion
 * Returns the current conditions for all sensors reported by Sense that is
 * paired to the account.
 *
 * @param block to call upon completion
 */
- (void)sensorStatus:(HEMSensorStatusHandler)completion;

/**
 * @discussion
 * Returns the room data for specified list of Sensors
 *
 * @param sensors: list of sensors to retrieve data for
 * @param completion: the block to call upon completion
 */
- (void)dataForSensors:(NSArray<SENSensor*>*)sensors
            completion:(HEMSensorDataHandler)completion;

/**
 * @description
 * Continuously poll for data at a set interval for all sensors, except what is
 * specified to be excluded.  If a poll request has been started, it will attempt
 * to override the current request with the new incoming request
 *
 * @param sensorTypes: types of sensors to exclude from
 * @param completion: the callback to call on each refresh
 */
- (void)pollDataForSensorsExcept:(NSSet<NSNumber*>*)sensorTypes completion:(HEMSensorPollHandler)completion;

/**
 * @description
 * Continuously poll for data at a set interval for the specified sensor and scope.
 *
 * @param type: type of sensort to poll data for
 * @param scope: scope of the data to be polled for
 * @param completion: the callback to call on each refresh
 */
- (void)pollDataForSensorType:(SENSensorType)type
                    withScope:(HEMSensorServiceScope)scope
                   completion:(HEMSensorPollHandler)completion;

/**
 * @description
 * Stop the polling when possible
 */
- (void)stopPollingForData;

@end

NS_ASSUME_NONNULL_END