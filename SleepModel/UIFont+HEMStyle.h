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

+ (UIFont*)h1;
+ (UIFont*)h2;
+ (UIFont*)h3;
+ (UIFont*)h4;
+ (UIFont*)h5;
+ (UIFont*)h6;
+ (UIFont*)h6Bold;
+ (UIFont*)h7;
+ (UIFont*)h7Bold;
+ (UIFont*)h8;
+ (UIFont*)body;
+ (UIFont*)bodyBold;
+ (UIFont*)bodySmall;
+ (UIFont*)bodySmallBold;
+ (UIFont*)buttonLarge;
+ (UIFont*)button;
+ (UIFont*)buttonSmall;

#pragma mark - Common fonts

/**
 *  Font for settings table cell titles
 */
+ (UIFont*)settingsTableCellFont;

/**
 *  Font for settings detail items, like sensor value and next alarm time
 */
+ (UIFont*)settingsTableCellDetailFont;

/**
 * Font used for the help text in settings
 */
+ (UIFont*)settingsHelpFont;

#pragma mark -

+ (UIFont*)alarmNumberFont;
+ (UIFont*)alarmSelectedNumberFont;
+ (UIFont*)alarmButtonFont;
+ (UIFont*)alarmMeridiemFont;
+ (UIFont*)sensorUnitFontForUnit:(SENSensorUnit)unit;
+ (UIFont*)timelineHistoryScoreFontOfSize:(CGFloat)size;

/**
 *  Font for event message text in the timeline
 */
+ (UIFont*)timelineEventMessageFont;

/**
 *  Font for timeline statistics titles
 */
+ (UIFont*)timelineBreakdownTitleFont;

/**
 *  Font for timeline statistics message summary
 */
+ (UIFont*)timelineBreakdownMessageFont;
+ (UIFont*)timelineBreakdownMessageBoldFont;

/**
 *  Font used to display average values in Trends v2
 */
+ (UIFont*)trendAverageValueFont;

/**
 *  Font for the v2 Trends sleep depth percentage values
 */
+ (UIFont*)trendSleepDepthValueFontWithSize:(CGFloat)size;

@end
