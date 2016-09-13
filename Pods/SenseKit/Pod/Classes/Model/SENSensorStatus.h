//
//  SENSensorStatus.h
//  Pods
//
//  Created by Jimmy Lu on 9/6/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"
#import "SENSensor.h"

typedef NS_ENUM(NSUInteger, SENSensorState) {
    SENSensorStateUnknown = 0,
    SENSensorStateOk,
    SENSensorStateNoSense,
    SENSensorStateWaiting
};

@interface SENSensorStatus : NSObject <SENSerializable>

@property (nonatomic, assign, readonly) SENSensorState state;
@property (nonatomic, strong, readonly) NSArray<SENSensor*>* sensors;

@end
