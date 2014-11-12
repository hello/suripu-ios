//
//  UIFont+HEMStyle.h
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (HEMStyle)

+ (UIFont *)alarmMessageFont;

+ (UIFont *)alarmMessageBoldFont;

/**
 *  Font for section and insight headings
 */
+ (UIFont *)insightTitleFont;

/**
 * Font for the title displayed on insight cards
 */
+ (UIFont *)insightCardTitleFont;

/**
 * Font for the message displayed on insight cards
 */
+ (UIFont *)insightCardMessageFont;

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
 *  Bold font for numbers
 */
+ (UIFont *)sensorGraphNumberBoldFont;

/**
 *  Font for headings at the top of each graph section
 */
+ (UIFont *)sensorGraphHeadingFont;

/**
 *  Bold font for headings at the top of each graph section
 */
+ (UIFont *)sensorGraphHeadingBoldFont;

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

/**
 *  Font to display the answers for questions
 */
+ (UIFont *)questionAnswerFont;

/**
 *  Font for the title when display question + answers
 */
+ (UIFont *)questionTitleFont;

/**
 *  Font for actual question
 */
+ (UIFont *)questionFont;

/**
 *  Font for display any Thank You text
 */
+ (UIFont *)thankyouFont;

/**
 *  Font used to display the blue toast that appears at the bottom of screen
 */
+ (UIFont *)infoToastFont;

/**
 * Font used to display activity status full screen
 */
+ (UIFont *)onboardingActivityFontLarge;

/**
 * Font used to display activity status within another view, typically
 */
+ (UIFont *)onboardingActivityFontMedium;

@end
