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

@implementation HEMMathUtil

BOOL IsMetricSystem () {
    NSLocale *locale = [NSLocale currentLocale];
    return [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

long ToInches (NSNumber* centimeters) {
    return [centimeters longValue] / HEMMathCentimetersPerInch;
}

float ToPounds (NSNumber* grams) {
    return [grams longValue] * HEMMathPoundsPerGram;
}

float ToKilograms (NSNumber* pounds) {
    return [pounds integerValue] * HEMMathKilogramsPerPound;
}

@end
