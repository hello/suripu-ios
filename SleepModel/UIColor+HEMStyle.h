//
//  UIColor+HEMStyle.h
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenseKit/SENSensor.h>

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

+ (UIColor*)colorForSensorWithCondition:(SENSensorCondition)condition;

@end
