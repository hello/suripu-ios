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
double const HEMMathPoundsPerGram = 0.00220462f;

BOOL HEMIsMetricSystem () {
    NSLocale *locale = [NSLocale currentLocale];
    return [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

float HEMToInches (NSNumber* centimeters) {
    return [centimeters floatValue] / HEMMathCentimetersPerInch;
}

float HEMToPounds (NSNumber* grams) {
    return [grams floatValue] * HEMMathPoundsPerGram;
}

float HEMToKilograms (NSNumber* pounds) {
    return [pounds floatValue] * HEMMathKilogramsPerPound;
}

float HEMDegreesToRadians(float degrees) {
    return  (degrees / 180.0) * M_PI;
}
