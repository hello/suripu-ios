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

+ (UIColor*)colorForSleepDepth:(NSUInteger)sleepDepth
{
    if (sleepDepth == 0)
        return [HelloStyleKit lightSleepColor];
    else if (sleepDepth == 100)
        return [HelloStyleKit deepSleepColor];
    else if (sleepDepth < 60)
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
