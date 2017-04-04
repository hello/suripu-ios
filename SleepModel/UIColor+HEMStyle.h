//
//  UIColor+HEMStyle.h
//  Sense
//
//  Deprecated: Use SenseStyle instead
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenseKit/SENCondition.h>
#import <SenseKit/SENTimelineSegment.h>

@interface UIColor (HEMStyle)

#pragma mark - Standard Hello Colors from Style Guide

#pragma mark Greys

+ (UIColor*)grey1;
+ (UIColor*)grey2;
+ (UIColor*)grey3;
+ (UIColor*)grey4;
+ (UIColor*)grey5;
+ (UIColor*)grey6;
+ (UIColor*)grey7;

#pragma mark Purple

+ (UIColor*)purple1;
+ (UIColor*)purple2;
+ (UIColor*)purple3;
+ (UIColor*)purple4;
+ (UIColor*)purple5;
+ (UIColor*)purple6;
+ (UIColor*)purple7;

#pragma mark Blue

+ (UIColor*)blue1;
+ (UIColor*)blue2;
+ (UIColor*)blue3;
+ (UIColor*)blue4;
+ (UIColor*)blue5;
+ (UIColor*)blue6;
+ (UIColor*)blue7;

#pragma mark Green

+ (UIColor*)green1;
+ (UIColor*)green2;
+ (UIColor*)green3;
+ (UIColor*)green4;
+ (UIColor*)green5;
+ (UIColor*)green6;
+ (UIColor*)green7;

#pragma mark Yellow

+ (UIColor*)yellow1;
+ (UIColor*)yellow2;
+ (UIColor*)yellow3;
+ (UIColor*)yellow4;
+ (UIColor*)yellow5;
+ (UIColor*)yellow6;
+ (UIColor*)yellow7;

#pragma mark Orange

+ (UIColor*)orange1;
+ (UIColor*)orange2;
+ (UIColor*)orange3;
+ (UIColor*)orange4;
+ (UIColor*)orange5;
+ (UIColor*)orange6;
+ (UIColor*)orange7;

#pragma mark Red

+ (UIColor*)red1;
+ (UIColor*)red2;
+ (UIColor*)red3;
+ (UIColor*)red4;
+ (UIColor*)red5;
+ (UIColor*)red6;
+ (UIColor*)red7;

#pragma mark - Timeline colors

/**
 *  Color used for a condition indicating item quality
 */
+ (UIColor *)colorForCondition:(SENCondition)condition;

/**
 *  Creates a UIColor instance from a hex value, such as 0xFF0000 (red)
 *
 *  @param hexValue value of the color to create
 *  @param alpha    intended alpha value
 *
 *  @return a color
 */
+ (UIColor *)colorWithHex:(uint)hexValue alpha:(float)alpha;
+ (UIColor *)timelineBackgroundColor;

#pragma mark - Background Colors

/**
 * Default background color for most views in view controllers
 */
+ (UIColor *)backgroundColor;

#pragma mark - Common colors

/**
 * Primary UI color
 */
+ (UIColor *)tintColor;

/**
 * Color used when action items are disabled
 */
+ (UIColor *)disabledColor;

+ (UIColor *)boldTextColor;
/**
 * Default text color
 */
+ (UIColor *)textColor;

/**
 * Text color for detail / value text, typically within a list / table view
 */
+ (UIColor *)detailTextColor;
+ (UIColor *)lowImportanceTextColor;

/**
 * Color of our navigation bar
 */
+ (UIColor *)navigationBarColor;
+ (UIColor *)subNavActiveTitleColor;
+ (UIColor *)subNavInactiveTitleColor;
+ (UIColor *)separatorColor;
+ (UIColor *)borderColor;
+ (NSArray*)loadingIndicatorColorRefs;


@end
