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

/**
 *  Color used for a condition indicating item quality
 */
+ (UIColor *)colorForCondition:(SENCondition)condition;

/**
 *  Color used for a state of sleep, such as awake, sound, or light
 */
+ (UIColor *)colorForSleepState:(SENTimelineSegmentSleepState)state;

/**
 * @deprecated
 * Removed in favor of colorForSleepState:
 * Slated for deletion after trends v2
 */
+ (UIColor *)colorForSleepScore:(NSInteger)score;

/**
 *  Creates a UIColor instance from a hex value, such as 0xFF0000 (red)
 *
 *  @param hexValue value of the color to create
 *  @param alpha    intended alpha value
 *
 *  @return a color
 */
+ (UIColor *)colorWithHex:(uint)hexValue alpha:(float)alpha;

/**
 *  Primary UI color
 */
+ (UIColor *)tintColor;

#pragma mark - Palette

#pragma mark Conditions
/**
 *  Condition color for the "WARNING" condition
 */
+ (UIColor *)warningSensorColor;

/**
 *  Condition color for the "IDEAL" condition
 */
+ (UIColor *)idealSensorColor;

/**
 *  Condition color for the "ALERT" condition
 */
+ (UIColor *)alertSensorColor;

/**
 *  Condition color for the "UNKNOWN" condition
 */
+ (UIColor *)unknownSensorColor;

#pragma mark - Sleep state

/**
 *  Color for the "LIGHT" sleep state
 */
+ (UIColor *)lightSleepColor;

/**
 *  Color for the "MEDIUM" sleep state
 */
+ (UIColor *)intermediateSleepColor;

/**
 *  Color for the "SOUND" sleep state
 */
+ (UIColor *)deepSleepColor;

/**
 *  Color for the "AWAKE" sleep state
 */
+ (UIColor *)awakeSleepColor;

#pragma mark - UI Elements

+ (UIColor *)currentConditionsBackgroundColor;
+ (UIColor *)sleepQuestionBgColor;
+ (UIColor *)onboardingGrayColor;
+ (UIColor *)backViewBackgroundColor;
+ (UIColor *)backViewNavTitleColor;
+ (UIColor *)backViewTextColor;
+ (UIColor *)senseBlueColor;
+ (UIColor *)backViewTintColor;
+ (UIColor *)timelineSectionBorderColor;
+ (UIColor *)timelineGradientDarkColor;
+ (UIColor *)backViewDetailTextColor;
+ (UIColor *)barButtonDisabledColor;
+ (UIColor *)actionViewTitleTextColor;
+ (UIColor *)actionViewCancelButtonTextColor;
+ (UIColor *)buttonDividerColor;
+ (UIColor *)questionAnswerSelectedBgColor;
+ (UIColor *)questionAnswerSelectedTextColor;
+ (UIColor *)sleepScoreOvalColor;
+ (UIColor *)tabBarUnselectedColor;
+ (UIColor *)deviceAlertMessageColor;
+ (UIColor *)timelineLineColor;
+ (UIColor *)timelineInsightTintColor;
+ (UIColor *)separatorColor;
+ (UIColor *)onboardingDescriptionColor;
+ (UIColor *)onboardingTitleColor;
+ (UIColor *)textfieldPlaceholderFocusedColor;
+ (UIColor *)textfieldPlaceholderColor;
+ (UIColor *)rulerSegmentDarkColor;
+ (UIColor *)rulerSegmentLightColor;
+ (UIColor *)settingsValueTextColor;
+ (UIColor *)textfieldTextColor;
+ (UIColor *)actionButtonTextColor;
+ (UIColor *)alarmSelectionRowColor;
+ (UIColor *)pageControlTintColor;
+ (UIColor *)actionButtonDisabledColor;
+ (UIColor *)backViewCardShadowColor;
+ (UIColor *)lightTintColor;
+ (UIColor *)trendTextColor;
+ (UIColor *)cardBorderColor;
+ (UIColor *)trendGraphBottomColor;
+ (UIColor *)trendGraphTopColor;
+ (UIColor *)switchOffBackgroundColor;
+ (UIColor *)buttonContainerShadowColor;
+ (UIColor *)timelineGradientColor;
+ (UIColor *)timelineGradientColor2;
+ (UIColor *)tutorialBackgroundColor;
+ (UIColor *)handholdingGestureHintColor;
+ (UIColor *)handholdingGestureHintBorderColor;
+ (UIColor *)handholdingMessageBackgroundColor;
+ (UIColor *)actionSheetSeparatorColor;
+ (UIColor *)actionSheetSelectedColor;
+ (UIColor *)timelineBarGradientColor;
+ (UIColor *)timelineBarGradientColor2;
+ (UIColor *)timelineEventShadowColor;

@end
