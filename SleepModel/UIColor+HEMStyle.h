//
//  UIColor+HEMStyle.h
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenseKit/SENSensor.h>

extern NSUInteger const HEMSleepScoreUnknown;
extern NSUInteger const HEMSleepScoreLow;
extern NSUInteger const HEMSleepScoreMedium;
extern NSUInteger const HEMSleepScoreHigh;

@interface UIColor (HEMStyle)

/**
 *  Returns the corresponding color style for the depth of sleep between
 *  0 (awake) and 100 (deep sleep)
 *
 *  @param sleepDepth depth of sleep
 *
 *  @return color
 */
+ (UIColor*)colorForSleepDepth:(NSUInteger)sleepDepth;

+ (UIColor*)colorForGenericMotionDepth:(NSUInteger)depth;

+ (UIColor*)colorForSensorWithCondition:(SENSensorCondition)condition;

+ (UIColor*)colorForSleepScore:(NSInteger)sleepScore;

@end
