//
//  SENAPISensor.h
//  Pods
//
//  Created by Jimmy Lu on 9/1/16.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENSensor;
@class SENSensorDataRequest;

NS_ASSUME_NONNULL_BEGIN

@interface SENAPISensor : NSObject

/**
 * @description
 * Get the status of sensors as a SENSensorStatus object
 * 
 * @param completion: the block to call upon completion
 */
+ (void)getSensorStatus:(SENAPIDataBlock)completion;

/**
 * @description
 * Get data points for sensor(s) specified in the request.  For each sensor
 * requested, an object representing the sensor and it's data is returned in
 * a dictionary format:
 * 
 *      SENSOR_TYPE : [<SENSensorDataPoint>,...]
 *
 * @param request: the data request object
 * @param completion: the block to call upon completion
 */
+ (void)getSensorDataWithRequest:(SENSensorDataRequest*)request
                      completion:(SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END