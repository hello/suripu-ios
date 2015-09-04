//
//  HEMSensorValueFormatter.m
//  Sense
//
//  Created by Jimmy Lu on 8/5/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMSensorValueFormatter.h"

@interface HEMSensorValueFormatter()

@property (nonatomic, assign) SENSensorUnit sensorUnit;

@end

@implementation HEMSensorValueFormatter

- (id)init {
    self = [super init];
    if (self) {
        [self setCommonProperties];
    }
    return self;
}

- (instancetype)initWithSensorUnit:(SENSensorUnit)unit {
    self = [super init];
    if (self) {
        [self setCommonProperties];
        [self setSensorUnit:unit];
    }
    return self;
}

- (void)setCommonProperties {
    [self setRoundingMode:NSNumberFormatterRoundUp];
    [self setMinimumIntegerDigits:1];
    [self setNilSymbol:NSLocalizedString(@"empty-data", nil)];
}

- (void)setNumberOfFractionDigits:(NSUInteger)digits {
    [self setMinimumFractionDigits:digits];
    [self setMaximumFractionDigits:digits];
}

- (NSString *)stringFromSensorValue:(NSNumber *)value {
    if (!value) {
        // why do it manually like this?  stringFromNumber: and stringForObjectValue:
        // does not actually return the nilSymbol when value is nil.  stringFromNumber:
        // is intended to return nil for nil, but stringForObjectValue: is suppose to
        // return the nilSymbol if value is nil.  bug in iOS?
        return [self nilSymbol];
    }
    
    NSNumber* preferredValue = [SENSensor value:value inPreferredUnit:[self sensorUnit]];
    switch ([self sensorUnit]) {
        case SENSensorUnitLux: {
            if ([preferredValue floatValue] < 10)
                [self setNumberOfFractionDigits:2];
            else if ([preferredValue floatValue] < 100)
                [self setNumberOfFractionDigits:1];
            else
                [self setNumberOfFractionDigits:0];
            break;
        }
        case SENSensorUnitAQI:
        case SENSensorUnitDecibel:
        case SENSensorUnitDegreeCentigrade:
        case SENSensorUnitPercent:
        case SENSensorUnitUnknown:
        default:
            [self setNumberOfFractionDigits:0];
            break;
    }
    
    return [self stringFromNumber:preferredValue];
}

- (NSString *)stringFromSensor:(SENSensor *)sensor {
    return [self stringFromNumber:[sensor value] forSensorUnit:[sensor unit]];
}

- (NSString *)stringFromNumber:(NSNumber *)number forSensorUnit:(SENSensorUnit)unit {
    [self setSensorUnit:unit];
    return [self stringFromSensorValue:number];
}

@end
