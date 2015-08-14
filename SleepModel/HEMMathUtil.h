//
//  HEMMathUtil.h
//  Sense
//
//  Created by Jimmy Lu on 9/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Converts centimeters to inches
 * @param centimeters: centimeters to convert to inches
 * @param inches
 */
float HEMToInches (NSNumber* centimeters);

/**
 * Converts grams to pounds
 * @param grams: NSNumber representing the grams to convert
 * @return pounds as a float value
 */
float HEMToPounds (NSNumber* grams);

/**
 * Converts pounds to kilograms
 * @param pounds: NSNumber representing the pounds to convert
 * @return kilograms as a float
 */
float HEMToKilograms (NSNumber* pounds);

/**
 * Convert degrees to radians
 @ return radian value for degrees
 */
float HEMDegreesToRadians(float degrees);
