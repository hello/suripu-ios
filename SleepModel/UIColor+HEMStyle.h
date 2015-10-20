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
+ (UIColor *)conditionWarningColor;

/**
 *  Condition color for the "IDEAL" condition
 */
+ (UIColor *)conditionIdealColor;

/**
 *  Condition color for the "ALERT" condition
 */
+ (UIColor *)conditionAlertColor;

/**
 *  Condition color for the "UNKNOWN" condition
 */
+ (UIColor *)conditionUnknownColor;

#pragma mark - Sleep state

/**
 *  Color for the "LIGHT" sleep state
 */
+ (UIColor *)sleepStateLightColor;

/**
 *  Color for the "MEDIUM" sleep state
 */
+ (UIColor *)sleepStateMediumColor;

/**
 *  Color for the "SOUND" sleep state
 */
+ (UIColor *)sleepStateSoundColor;

/**
 *  Color for the "AWAKE" sleep state
 */
+ (UIColor *)sleepStateAwakeColor;

#pragma mark - UI Elements

+ (UIColor *)onboardingGrayColor;
+ (UIColor *)backViewBackgroundColor;
+ (UIColor *)backViewNavTitleColor;
+ (UIColor *)backViewTextColor;
+ (UIColor *)backViewTintColor;
+ (UIColor *)barButtonDisabledColor;
+ (UIColor *)actionViewTitleTextColor;
+ (UIColor *)actionViewCancelButtonTextColor;
+ (UIColor *)alertBackgroundColor;
+ (UIColor *)alertBooleanSecondaryColor;
+ (UIColor *)buttonDividerColor;
+ (UIColor *)questionAnswerSelectedBgColor;
+ (UIColor *)questionAnswerSelectedTextColor;
+ (UIColor *)sleepScoreOvalColor;
+ (UIColor *)deviceAlertMessageColor;
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
+ (UIColor *)lightTintColor;
+ (UIColor *)trendTextColor;
+ (UIColor *)cardBorderColor;
+ (UIColor *)trendGraphBottomColor;
+ (UIColor *)trendGraphTopColor;
+ (UIColor *)switchOffBackgroundColor;
+ (UIColor *)timelineGradientColor;
+ (UIColor *)tutorialBackgroundColor;
+ (UIColor *)handholdingGestureHintColor;
+ (UIColor *)handholdingGestureHintBorderColor;
+ (UIColor *)handholdingMessageBackgroundColor;
+ (UIColor *)actionSheetSeparatorColor;
+ (UIColor *)actionSheetSelectedColor;
+ (UIColor *)timelineSelectedBackgroundColor;
+ (UIColor *)timelineAccentColor;
+ (UIColor *)timelineWaveformColor;
+ (UIColor *)welcomeTitleColor;
+ (UIColor *)welcomeDescriptionColor;
+ (UIColor *)welcomeVideoButtonColor;
+ (UIColor *)welcomeIntroTitleColor;
+ (UIColor *)welcomeIntroDescriptionColor;
+ (NSArray *)timelineSelectedGradientColorRefs;
+ (NSArray*)roomCheckValueGradientColorRefs;

@end
