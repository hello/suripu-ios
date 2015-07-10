//
//  UIColor+HEMStyle.h
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenseKit/SENCondition.h>
#import <SenseKit/SENTimelineSegment.h>

@interface UIColor (HEMStyle)

+ (UIColor *)colorForCondition:(SENCondition)condition;
+ (UIColor *)colorForSleepState:(SENTimelineSegmentSleepState)state;
+ (UIColor *)colorForSleepDepth:(NSInteger)depth;

/**
 * @deprecated
 * Slated for deletion after trends v2
 */
+ (UIColor *)colorForSleepScore:(NSInteger)score;
@end
