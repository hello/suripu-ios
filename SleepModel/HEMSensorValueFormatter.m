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

- (void)setSensorUnit:(SENSensorUnit)unit {
    if (unit == _sensorUnit) {
        return;
    }
    
    _sensorUnit = unit;
    
    switch (unit) {
        case SENSensorUnitLux: {
            [self setNumberOfFractionDigits:2];
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
    // calculate the powers of 10 of the value and subtract that number from the
    // min fraction digits to ensure a 3 digit display, which is not the same as
    // 3 significant digits
    CGFloat defaultMinFraction = [self minimumFractionDigits];
    NSUInteger powers = MAX(log10f([value floatValue]), 0);
    NSUInteger minFraction = MIN(defaultMinFraction - powers, defaultMinFraction);
    [self setMaximumFractionDigits:minFraction];
    return [self stringFromNumber:value];
}

- (NSString *)stringFromSensor:(SENSensor *)sensor {
    return [self stringFromNumber:[sensor valueInPreferredUnit]
                    forSensorUnit:[sensor unit]];
}

- (NSString *)stringFromNumber:(NSNumber *)number forSensorUnit:(SENSensorUnit)unit {
    [self setSensorUnit:unit];
    return [self stringFromSensorValue:number];
}

@end
