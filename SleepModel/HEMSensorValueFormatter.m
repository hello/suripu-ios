//
//  HEMSensorValueFormatter.m
//  Sense
//
//  Created by Jimmy Lu on 8/5/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <CoreText/CoreText.h>

#import <SenseKit/SENPreference.h>

#import "HEMSensorValueFormatter.h"
#import "HEMMathUtil.h"

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
    [self setUnicodeUnitSymbol:YES];
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
    
    switch ([self sensorUnit]) {
        case SENSensorUnitLux: {
            BOOL showFraction = [value doubleValue] < 10;
            [self setNumberOfFractionDigits:showFraction ? 1 : 0];
            break;
        }
        case SENSensorUnitCelsius: {
            value = [self convertValue:value];
            [self setNumberOfFractionDigits:0];
            break;
        }
        case SENSensorUnitFahrenheit: {
            value = [self convertValue:value];
            [self setNumberOfFractionDigits:0];
            break;
        }
        default:
            [self setNumberOfFractionDigits:0];
            break;
    }
    
    NSString* valueString = [self stringFromNumber:value];
    if ([self includeUnitSymbol]) {
        valueString = [valueString stringByAppendingString:[self unitSymbol]];
    }
    return valueString;
}

- (NSNumber*)convertValue:(NSNumber*)value {
    switch ([self sensorUnit]) {
        case SENSensorUnitCelsius: {
            if (![SENPreference useCentigrade]) {
                // if zero, leave it as zero
                if ([value doubleValue] == 0.0f) {
                    value = @0;
                } else {
                    value = @(HEMCelsiusToFahrenheit([value doubleValue]));
                }
            }
            return value;
        }
        case SENSensorUnitFahrenheit: {
            if ([SENPreference useCentigrade]) {
                value = @(HEMFahrenheitToCelsius([value doubleValue]));
            }
            return value;
        }
        default:
            return value;
    }
}

- (NSString *)stringFromSensor:(SENSensor *)sensor {
    return [self stringFromNumber:[sensor value] forSensorUnit:[sensor unit]];
}

- (NSString *)stringFromNumber:(NSNumber *)number forSensorUnit:(SENSensorUnit)unit {
    [self setSensorUnit:unit];
    return [self stringFromSensorValue:number];
}

- (NSAttributedString*)attributedValue:(NSNumber*)value
                    unitSymbolLocation:(HEMSensorValueUnitLoc)location
                       valueAttributes:(NSDictionary*)valueAttributes
                        unitAttributes:(NSDictionary*)unitAttributes {
    // turn it off momentarily so that it can be separately added
    BOOL includeUnit = [self includeUnitSymbol];
    [self setIncludeUnitSymbol:NO];
    
    NSMutableAttributedString* attributedString = nil;
    NSString* valueString = [self stringFromSensorValue:value];
    
    if (valueString) {
        attributedString = [[NSMutableAttributedString alloc] initWithString:valueString attributes:valueAttributes];
        if (includeUnit) {
            NSString* unitSymbol = [self unitSymbol];
            if (unitSymbol) {
                NSMutableDictionary* unitAtts = [unitAttributes mutableCopy];
                if (!unitAtts) {
                    unitAtts = [NSMutableDictionary dictionaryWithCapacity:1];
                }
                [unitAtts setValue:@(location) forKey:(id)kCTSuperscriptAttributeName];
                
                NSAttributedString* attrUnit = [[NSAttributedString alloc] initWithString:unitSymbol attributes:unitAtts];
                [attributedString appendAttributedString:attrUnit];
            }
        }
    }
    
    [self setIncludeUnitSymbol:includeUnit]; // set it back to whatever it was
    return attributedString;
}

- (NSAttributedString*)attributedValueFromSensor:(SENSensor*)sensor
                              unitSymbolLocation:(HEMSensorValueUnitLoc)location
                                 valueAttributes:(NSDictionary*)valueAttributes
                                  unitAttributes:(NSDictionary*)unitAttributes {
    [self setSensorUnit:[sensor unit]];
    return [self attributedValue:[sensor value]
              unitSymbolLocation:location
                 valueAttributes:valueAttributes
                  unitAttributes:unitAttributes];
}

- (NSString*)unitSymbol {
    switch ([self sensorUnit]) {
        case SENSensorUnitFahrenheit:
        case SENSensorUnitCelsius:
            if ([self useUnicodeUnitSymbol]) {
                return NSLocalizedString(@"measurement.temperature.unit", nil);
            } else {
                return NSLocalizedString(@"measurement.temperature.unit.normal", nil);
            }
        case SENSensorUnitPercent:
            return NSLocalizedString(@"measurement.percentage.unit", nil);
        case SENSensorUnitLux:
            return NSLocalizedString(@"measurement.light.unit", nil);
        case SENSensorUnitDecibel:
            return NSLocalizedString(@"measurement.sound.unit", nil);
        case SENSensorUnitMGCM:
            return NSLocalizedString(@"measurement.particle.unit", nil);
        case SENSensorUnitPPM:
            return NSLocalizedString(@"measurement.ppm.unit", nil);
        case SENSensorUnitMBar:
            return NSLocalizedString(@"measurement.mbar.unit", nil);
        default:
            return @"";
    }
}

@end
