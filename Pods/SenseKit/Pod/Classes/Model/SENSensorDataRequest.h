//
//  SENSensorDataRequest.h
//  Pods
//
//  Created by Jimmy Lu on 9/7/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSensor.h"

typedef NS_ENUM(NSUInteger, SENSensorDataMethod) {
    SENSensorDataMethodAverage = 0,
    SENSensorDataMethodMin,
    SENSensorDataMethodMax
};

typedef NS_ENUM(NSUInteger, SENSensorDataScope) {
    SENSensorDataScopeDay5Min = 0
};

NS_ASSUME_NONNULL_BEGIN

@interface SENSensorDataRequest : NSObject

@property (nonatomic, strong, readonly) NSUUID* identifier;

- (void)addRequestForSensor:(SENSensor*)sensor
                usingMethod:(SENSensorDataMethod)method
                  withScope:(SENSensorDataScope)scope;

- (void)addRequestForSensors:(NSArray<SENSensor*>*)sensors
                 usingMethod:(SENSensorDataMethod)method
                   withScope:(SENSensorDataScope)scope;

- (NSDictionary*)dictionaryValue;

@end

NS_ASSUME_NONNULL_END