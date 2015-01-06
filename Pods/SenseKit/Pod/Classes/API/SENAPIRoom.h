
#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENSensor;

@interface SENAPIRoom : NSObject

/**
 *  GET /room/current&temperature_unit=:unit
 *
 *  Fetch the current room conditions as an array of sensor data
 *
 *  @param completion block invoked when the network call is completed asynchronously
 */
+ (void)currentWithCompletion:(SENAPIDataBlock)completion;

/**
 *  GET /room/:sensorName/day?from=:date
 *
 *  Fetch historical values for a given sensor
 *
 *  @param sensor     sensor for data
 *  @param completion block invoked when the network call is completed asynchronously
 */
+ (void)hourlyHistoricalDataForSensor:(SENSensor*)sensor
                           completion:(SENAPIDataBlock)completion;

/**
 *  GET /room/:sensorName/week?from=:date
 *
 *  Fetch historical values for a given sensor
 *
 *  @param sensor     sensor for data
 *  @param completion block invoked when the network call is completed asynchronously
 */
+ (void)dailyHistoricalDataForSensor:(SENSensor*)sensor
                          completion:(SENAPIDataBlock)completion;

@end
