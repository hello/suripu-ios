//
//  HEMSensorService.m
//  Sense
//
//  Created by Jimmy Lu on 3/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSensor.h>

#import "HEMSensorService.h"

@implementation HEMSensorService

- (NSArray<SENSensor*>*)sortedCacheSensors {
    NSComparator comparator = [self preferredSensorOrderComparator];
    return [[SENSensor sensors] sortedArrayUsingComparator:comparator];
}

- (NSComparator)preferredSensorOrderComparator {
    return ^NSComparisonResult(SENSensor *obj1, SENSensor *obj2) {
        NSInteger obj1Index = [self preferredOrderIndexForSensor:obj1];
        NSInteger obj2Index = [self preferredOrderIndexForSensor:obj2];
        return [@(obj1Index) compare:@(obj2Index)];
    };
}

- (NSInteger)preferredOrderIndexForSensor:(SENSensor *)sensor {
    switch (sensor.unit) {
        case SENSensorUnitDegreeCentigrade:
            return 0;
        case SENSensorUnitPercent:
            return 1;
        case SENSensorUnitAQI:
            return 2;
        case SENSensorUnitLux:
            return 3;
        case SENSensorUnitDecibel:
            return 4;
        case SENSensorUnitUnknown:
        default:
            return 5;
    }
}

@end
