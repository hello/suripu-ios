//
//  HEMSensorValueFormatter.h
//  Sense
//
//  Created by Jimmy Lu on 8/5/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENSensor.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HEMSensorValueUnitLoc) {
    HEMSensorValueUnitLocNormal = 0,
    HEMSensorValueUnitLocSuperscript = 1,
    HEMSensorValueUnitLocSubscript = -1
};

@interface HEMSensorValueFormatter : NSNumberFormatter

@property (nonatomic, assign) BOOL includeUnitSymbol;

/**
 * @method initWithSensorUnit:
 *
 * @discussion
 * Initializes an instance with the specified sensor unit.  The value can be changed
 * be calling @method setSensorUnit:
 * 
 * @param unit: the sensor unit
 */
- (instancetype)initWithSensorUnit:(SENSensorUnit)unit;

/**
 * @method setSensorUnit:
 *
 * @discussion
 * Change the sensor unit to the specified unit, which determines the formatting
 * used when converting the value to the a string
 */
- (void)setSensorUnit:(SENSensorUnit)unit;

/**
 * @method stringFromSensorValue:
 *
 * @discussion
 * Formats the specified value using the configured sensor unit to determine the
 * formatting to use
 *
 * @param value: the value to format to a string
 * @return       the string representation for the numeric value
 */
- (NSString*)stringFromSensorValue:(NSNumber*)value;

/**
 * @method stringFromSensor:
 *
 * @discussion
 * Formats the specified sensor's value, in preferred unit, in to it's string
 * reresentation
 *
 * @param sensor: the sensor to format the value for
 * @return        the string representation of the sensor's value, in preferred unit
 */
- (NSString*)stringFromSensor:(SENSensor*)sensor;

/**
 * @method stringFromSensor:
 *
 * @discussion
 * Formats the specified sensor's value, in preferred unit, in to it's string
 * reresentation
 *
 * @param sensor: the sensor to format the value for
 * @return        the string representation of the sensor's value, in preferred unit
 */
- (NSString*)stringFromNumber:(NSNumber *)number forSensorUnit:(SENSensorUnit)unit;

/**
 * @discussion
 * Convenience method to return the symbol that represents the unit set in this
 * formatter
 * 
 * @return unit symbol, if available
 */
- (NSString*)unitSymbol;

/**
 * @discussion
 * Return an attributed value string containing the unit symbol.  This only applies
 * if includeUnitSymbol is YES.  If that property is NO, then attributed string
 * will simply be the formatted value.
 *
 * @param sensor: sensor to process
 * @param location: the location of the unit symbol, if includeUnitSymbol is YES
 * @param valueAttributes: attributes to be applied to the sensor value itself
 * @param unitAttributes: attributes to be applied to the sensor unit symbol
 */
- (NSAttributedString*)attributedValueFromSensor:(SENSensor*)sensor
                              unitSymbolLocation:(HEMSensorValueUnitLoc)location
                                 valueAttributes:(NSDictionary*)valueAttributes
                                  unitAttributes:(NSDictionary*)unitAttributes;

/**
 * @discussion
 * Convert the value based on the unit to the preferred unit.  For example, if
 * unit is celsius, but preferred unit is fahrenheit, the returned value will
 * be the degrees in fahrenheit;
 * 
 * @param value: value to convert
 * @return the converted value, if applicable
 */
- (NSNumber*)convertValue:(NSNumber*)value;

@end
