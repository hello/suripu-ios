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
 * @return inches
 */
CGFloat HEMToInches (NSNumber* centimeters);

/**
 * Converts inches to centimeters
 * @param inches: inches to convert to centimeters
 * @return centimeters
 */
CGFloat HEMToCm (NSNumber* inches);

/**
 * Converts grams to pounds
 * @param grams: NSNumber representing the grams to convert
 * @return pounds
 */
CGFloat HEMGramsToPounds (NSNumber* grams);

/**
 * Converts grams to Kilograms
 * @param grams: NSNumber representing the grams to convert
 * @return Kilograms
 */
CGFloat HEMGramsToKilograms (NSNumber *grams);

/**
 * Converts pounds to kilograms
 * @param pounds: NSNumber representing the pounds to convert
 * @return kilograms
 */
CGFloat HEMPoundsToKilograms (NSNumber* pounds);

/**
 * Converts pounds to grams
 * @param pounds: NSNumber representing the pounds to convert
 * @return grams
 */
CGFloat HEMPoundsToGrams (NSNumber* pounds);

/**
 * Convert degrees to radians
 @ return radian value for degrees
 */
CGFloat HEMDegreesToRadians(CGFloat degrees);
