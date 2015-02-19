//
//  UIColor+HEMStyle.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSleepResult.h>
#import "UIColor+HEMStyle.h"
#import "HelloStyleKit.h"

NSUInteger const HEMSleepScoreUnknown = 0;
NSUInteger const HEMSleepScoreLow = 50;
NSUInteger const HEMSleepScoreMedium = 80;
NSUInteger const HEMSleepScoreHigh = 100;

@implementation UIColor (HEMStyle)

+ (UIColor*)colorForGenericMotionDepth:(NSUInteger)depth
{
    if (depth == SENSleepResultSegmentDepthAwake)
        return [UIColor whiteColor];
    else if (depth == SENSleepResultSegmentDepthDeep)
        return [UIColor colorWithWhite:0.94 alpha:1.f];
    else if (depth < SENSleepResultSegmentDepthMedium)
        return [UIColor colorWithWhite:0.99 alpha:1.f];
    else
        return [UIColor colorWithWhite:0.97 alpha:1.f];
}

+ (UIColor*)colorForSleepDepth:(NSUInteger)sleepDepth
{
    if (sleepDepth == SENSleepResultSegmentDepthAwake)
        return [HelloStyleKit lightSleepColor];
    else if (sleepDepth == SENSleepResultSegmentDepthDeep)
        return [HelloStyleKit deepSleepColor];
    else if (sleepDepth < SENSleepResultSegmentDepthMedium)
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
    if (sleepScore == HEMSleepScoreUnknown)
        return [HelloStyleKit unknownSensorColor];
    else if (sleepScore < HEMSleepScoreLow)
        return [HelloStyleKit alertSensorColor];
    else if (sleepScore < HEMSleepScoreMedium)
        return [HelloStyleKit warningSensorColor];
    else
        return [HelloStyleKit idealSensorColor];
}

@end
