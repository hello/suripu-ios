//
//  HEMMathUtil.m
//  Sense
//
//  Created by Jimmy Lu on 9/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMMathUtil.h"

CGFloat const HEMMathCentimetersPerInch = 2.54f;
CGFloat const HEMMathKilogramsPerPound = 0.453592f;
CGFloat const HEMMathPoundsPerGram = 0.0022046f;
CGFloat const HEMMathGramsPerPound = 453.592f;

CGFloat HEMToInches (NSNumber* centimeters) {
    return round([centimeters doubleValue] / HEMMathCentimetersPerInch);
}

CGFloat HEMGramsToKilograms (NSNumber *grams) {
    return [grams doubleValue] / 1000.0f;
}

CGFloat HEMGramsToPounds (NSNumber* grams) {
    return [grams doubleValue] * HEMMathPoundsPerGram;
}

CGFloat HEMPoundsToKilograms (NSNumber* pounds) {
    return [pounds doubleValue] * HEMMathKilogramsPerPound;
}

CGFloat HEMPoundsToGrams (NSNumber* pounds) {
    return [pounds doubleValue] * HEMMathGramsPerPound;
}

CGFloat HEMDegreesToRadians(CGFloat degrees) {
    return  (degrees / 180.0) * M_PI;
}
