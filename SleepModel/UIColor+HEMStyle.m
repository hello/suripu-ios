//
//  UIColor+HEMStyle.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIColor+HEMStyle.h"
#import "HelloStyleKit.h"

@implementation UIColor (HEMStyle)

static CGFloat const HEMColorAwakeThreshold = 0;
static CGFloat const HEMColorDeepThreshold = 100.f;
static CGFloat const HEMColorLightThreshold = 1.f;
static CGFloat const HEMColorMediumThreshold = 60.f;

+ (UIColor*)colorForGenericMotionDepth:(NSUInteger)depth
{
    if (depth == HEMColorAwakeThreshold)
        return [UIColor whiteColor];
    else if (depth == HEMColorDeepThreshold)
        return [UIColor colorWithWhite:0.99 alpha:1.f];
    else if (depth < HEMColorMediumThreshold)
        return [UIColor colorWithWhite:0.94 alpha:1.f];
    else
        return [UIColor colorWithWhite:0.97 alpha:1.f];
}

+ (UIColor*)colorForSleepDepth:(NSUInteger)sleepDepth
{
    if (sleepDepth == HEMColorAwakeThreshold)
        return [HelloStyleKit lightSleepColor];
    else if (sleepDepth == HEMColorDeepThreshold)
        return [HelloStyleKit deepSleepColor];
    else if (sleepDepth < HEMColorMediumThreshold)
        return [HelloStyleKit lightSleepColor];
    else
        return [HelloStyleKit intermediateSleepColor];
}

+ (UIColor *)colorForSensorWithCondition:(SENSensorCondition)condition
{
    switch (condition) {
        case SENSensorConditionAlert:
            return [HelloStyleKit alertSensorColor];
        case SENSensorConditionWarning:
            return [HelloStyleKit warningSensorColor];
        case SENSensorConditionIdeal:
            return [HelloStyleKit idealSensorColor];
        default:
            return [HelloStyleKit unknownSensorColor];
    }
}

+ (UIColor *)colorForSleepScore:(NSInteger)sleepScore
{
    if (sleepScore == 0)
        return [HelloStyleKit unknownSensorColor];
    else if (sleepScore < 45)
        return [HelloStyleKit alertSensorColor];
    else if (sleepScore < 80)
        return [HelloStyleKit warningSensorColor];
    else
        return [HelloStyleKit idealSensorColor];
}

@end
