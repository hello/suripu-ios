
#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@interface SENAPIRoom : NSObject

/**
 *  GET /room/current
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
 *  @param sensorName name of the sensor for data
 *  @param completion block invoked when the network call is completed asynchronously
 */
+ (void)hourlyHistoricalDataForSensorWithName:(NSString*)sensorName
                                   completion:(SENAPIDataBlock)completion;

/**
 *  GET /room/:sensorName/week?from=:date
 *
 *  Fetch historical values for a given sensor
 *
 *  @param sensorName name of the sensor for data
 *  @param completion block invoked when the network call is completed asynchronously
 */
+ (void)dailyHistoricalDataForSensorWithName:(NSString*)sensorName
                                  completion:(SENAPIDataBlock)completion;

@end
