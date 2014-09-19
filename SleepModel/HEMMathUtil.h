//
//  HEMMathUtil.h
//  Sense
//
//  Created by Jimmy Lu on 9/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMMathUtil : NSObject

/**
 * Determines whether the current device is using the metric system or not
 * @return YES if metric system, NO otherwise
 */
BOOL IsMetricSystem (void);

/**
 * Converts centimeters to inches
 * @param centimeters: centimeters to convert to inches
 * @param inches
 */
long ToInches (NSNumber* centimeters);

/**
 * Converts grams to pounds
 * @param grams: NSNumber representing the grams to convert
 * @return pounds as a float value
 */
float ToPounds (NSNumber* grams);

/**
 * Converts pounds to kilograms
 * @param pounds: NSNumber representing the pounds to convert
 * @return kilograms as a float
 */
float ToKilograms (NSNumber* pounds);

@end
