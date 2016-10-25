//
//  HEMMathUtil.m
//  Sense
//
//  Created by Jimmy Lu on 9/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMMathUtil.h"

double const HEMMathCentimetersPerInch = 2.54f;
double const HEMMathKilogramsPerPound = 0.453592f;
double const HEMMathPoundsPerGram = 0.0022046f;
double const HEMMathGramsPerPound = 453.592f;

double HEMToInches (NSNumber* centimeters) {
    return [centimeters doubleValue] / HEMMathCentimetersPerInch;
}

double HEMToCm (NSNumber* inches) {
    return [inches doubleValue] * HEMMathCentimetersPerInch;
}

double HEMGramsToKilograms (NSNumber *grams) {
    return [grams doubleValue] / 1000.0f;
}

double HEMGramsToPounds (NSNumber* grams) {
    return [grams doubleValue] * HEMMathPoundsPerGram;
}

double HEMPoundsToKilograms (NSNumber* pounds) {
    return [pounds doubleValue] * HEMMathKilogramsPerPound;
}

double HEMPoundsToGrams (NSNumber* pounds) {
    return [pounds doubleValue] * HEMMathGramsPerPound;
}

double HEMDegreesToRadians(double degrees) {
    return  (degrees / 180.0) * M_PI;
}

double HEMCelsiusToFahrenheit(double celsius) {
    return (celsius * 1.8f) + 32.0f;
}

double HEMFahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) / 1.8f;
}
