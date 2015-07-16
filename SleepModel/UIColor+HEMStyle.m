//
//  UIColor+HEMStyle.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENTimeline.h>
#import "UIColor+HEMStyle.h"
#import "HelloStyleKit.h"

@implementation UIColor (HEMStyle)

+ (UIColor *)colorForCondition:(SENCondition)condition {
    switch (condition) {
        case SENConditionAlert:
            return [HelloStyleKit alertSensorColor];
        case SENConditionWarning:
            return [HelloStyleKit warningSensorColor];
        case SENConditionIdeal:
            return [HelloStyleKit idealSensorColor];
        default:
            return [HelloStyleKit unknownSensorColor];
    }
}

+ (UIColor *)colorForSleepState:(SENTimelineSegmentSleepState)state {
    switch (state) {
        case SENTimelineSegmentSleepStateAwake:
            return [HelloStyleKit awakeSleepColor];
        case SENTimelineSegmentSleepStateLight:
            return [HelloStyleKit lightSleepColor];
        case SENTimelineSegmentSleepStateMedium:
            return [HelloStyleKit intermediateSleepColor];
        case SENTimelineSegmentSleepStateSound:
            return [HelloStyleKit deepSleepColor];
        default:
            return [UIColor clearColor];
    }
}

+ (UIColor *)colorForSleepScore:(NSInteger)score {
    if (score == 0)
        return [HelloStyleKit unknownSensorColor];
    else if (score < 50)
        return [HelloStyleKit alertSensorColor];
    else if (score < 80)
        return [HelloStyleKit warningSensorColor];

    return [HelloStyleKit idealSensorColor];
}

@end
