//
//  SENSensorDataRequest.h
//  Pods
//
//  Created by Jimmy Lu on 9/7/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSensor.h"

typedef NS_ENUM(NSUInteger, SENSensorDataScope) {
    SENSensorDataScopeLast3H5Min = 0,
    SENSensorDataScopeDay5Min,
    SENSensorDataScopeWeek1Hour
};

NS_ASSUME_NONNULL_BEGIN

@interface SENSensorDataRequest : NSObject

@property (nonatomic, strong, readonly) NSUUID* identifier;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithScope:(SENSensorDataScope)scope NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)addSensor:(SENSensor*)sensor;
- (void)addSensors:(NSArray<SENSensor*>*)sensors;
- (NSDictionary*)dictionaryValue;

@end

NS_ASSUME_NONNULL_END