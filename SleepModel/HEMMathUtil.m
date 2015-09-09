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

float HEMToInches (NSNumber* centimeters) {
    return round([centimeters floatValue] / HEMMathCentimetersPerInch);
}

float HEMGramsToKilograms (NSNumber *grams) {
    return [grams floatValue] / 1000.0f;
}

float HEMGramsToPounds (NSNumber* grams) {
    return [grams floatValue] * HEMMathPoundsPerGram;
}

float HEMPoundsToKilograms (NSNumber* pounds) {
    return [pounds floatValue] * HEMMathKilogramsPerPound;
}

float HEMPoundsToGrams (NSNumber* pounds) {
    return [pounds floatValue] * HEMMathGramsPerPound;
}

float HEMDegreesToRadians(float degrees) {
    return  (degrees / 180.0) * M_PI;
}
