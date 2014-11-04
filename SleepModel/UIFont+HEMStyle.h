//
//  UIFont+HEMStyle.h
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (HEMStyle)

/**
 *  Font for section and insight headings
 */
+ (UIFont *)insightTitleFont;

/**
 *  Font for current sensor value and sleep score
 */
+ (UIFont *)largeNumberFont;

/**
 *  Font for insight message text
 */
+ (UIFont *)settingsInsightMessageFont;

/**
 *  Font for settings table cell titles
 */
+ (UIFont *)settingsTableCellFont;

/**
 *  Font for settings detail items, like sensor value and
 *  next alarm time
 */
+ (UIFont *)settingsTableCellDetailFont;

/**
 *  Navigation item title font
 */
+ (UIFont*)settingsTitleFont;

/**
 *  Font for sensor range selection from 'last 24 hours' and
 *  'last week'
 */
+ (UIFont *)sensorRangeSelectionFont;

/**
 *  Font for numbers at the bottom of each graph section
 */
+ (UIFont *)sensorGraphNumberFont;

/**
 *  Font for headings at the top of each graph section
 */
+ (UIFont *)sensorGraphHeadingFont;

/**
 *  Font for event message text in the timeline
 */
+ (UIFont *)timelineEventMessageFont;

/**
 *  Bold font for event message text in the timeline
 */
+ (UIFont *)timelineEventMessageBoldFont;

/**
 *  Font for tips at the bottom of event expansion
 */
+ (UIFont *)timelineEventTipFont;

/**
 *  Bold font for tips at the bottom of event expansion
 */
+ (UIFont *)timelineEventTipBoldFont;

/**
 *  Font for summary text above the timeline
 */
+ (UIFont *)timelineMessageFont;

/**
 *  Bold font for summary text above the timeline
 */
+ (UIFont *)timelineMessageBoldFont;

@end
