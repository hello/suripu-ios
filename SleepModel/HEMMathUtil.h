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
 * @return pounds
 */
float HEMGramsToPounds (NSNumber* grams);

/**
 * Converts grams to Kilograms
 * @param grams: NSNumber representing the grams to convert
 * @return Kilograms
 */
float HEMGramsToKilograms (NSNumber *grams);

/**
 * Converts pounds to kilograms
 * @param pounds: NSNumber representing the pounds to convert
 * @return kilograms
 */
float HEMPoundsToKilograms (NSNumber* pounds);

/**
 * Converts pounds to grams
 * @param pounds: NSNumber representing the pounds to convert
 * @return grams
 */
float HEMPoundsToGrams (NSNumber* pounds);

/**
 * Convert degrees to radians
 @ return radian value for degrees
 */
float HEMDegreesToRadians(float degrees);
