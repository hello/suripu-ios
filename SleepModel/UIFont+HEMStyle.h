//
//  UIFont+HEMStyle.h
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSensor.h>
#import <UIKit/UIKit.h>

@interface UIFont (HEMStyle)

#pragma mark - Style guide

+ (UIFont*)h1 DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h2 DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h3 DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h4 DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h5 DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h6 DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h6Bold DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h7 DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h7Bold DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h8 DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)h9 DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)body DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)bodyBold DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)bodySmall DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)bodySmallBold DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)buttonLarge DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)button DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");
+ (UIFont*)buttonSmall DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");

#pragma mark - Common fonts

/**
 *  Font for settings table cell titles
 */
+ (UIFont*)settingsTableCellFont DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");

/**
 * Font used for the help text in settings
 */
+ (UIFont*)settingsHelpFont DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");

#pragma mark -

+ (UIFont*)sensorUnitFontForUnit:(SENSensorUnit)unit;
+ (UIFont*)timelineHistoryScoreFontOfSize:(CGFloat)size;

/**
 *  Font used to display average values in Trends v2
 */
+ (UIFont*)trendAverageValueFont DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");

/**
 *  Font for the v2 Trends sleep depth percentage values
 */
+ (UIFont*)trendSleepDepthValueFontWithSize:(CGFloat)size DEPRECATED_MSG_ATTRIBUTE("Use SenseStyle instead");

@end
