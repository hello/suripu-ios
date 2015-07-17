//
//  UIColor+HEMStyle.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENTimeline.h>
#import "UIColor+HEMStyle.h"

@implementation UIColor (HEMStyle)

+ (UIColor *)colorForCondition:(SENCondition)condition {
    switch (condition) {
        case SENConditionAlert:
            return [self alertSensorColor];
        case SENConditionWarning:
            return [self warningSensorColor];
        case SENConditionIdeal:
            return [self idealSensorColor];
        default:
            return [self unknownSensorColor];
    }
}

+ (UIColor *)colorForSleepState:(SENTimelineSegmentSleepState)state {
    switch (state) {
        case SENTimelineSegmentSleepStateAwake:
            return [self awakeSleepColor];
        case SENTimelineSegmentSleepStateLight:
            return [self lightSleepColor];
        case SENTimelineSegmentSleepStateMedium:
            return [self intermediateSleepColor];
        case SENTimelineSegmentSleepStateSound:
            return [self deepSleepColor];
        default:
            return [UIColor clearColor];
    }
}

+ (UIColor *)colorWithHex:(uint)hexValue alpha:(float)alpha {
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hexValue & 0xFF00) >> 8)) / 255.0
                            blue:((float)(hexValue & 0xFF)) / 255.0
                           alpha:alpha];
}

+ (UIColor *)colorForSleepScore:(NSInteger)score {
    if (score == 0)
        return [self unknownSensorColor];
    else if (score < 50)
        return [self alertSensorColor];
    else if (score < 80)
        return [self warningSensorColor];

    return [self idealSensorColor];
}

#pragma mark - Palette

#pragma mark Cache

static UIColor *_warningSensorColor = nil;
static UIColor *_idealSensorColor = nil;
static UIColor *_alertSensorColor = nil;
static UIColor *_unknownSensorColor = nil;
static UIColor *_lightSleepColor = nil;
static UIColor *_intermediateSleepColor = nil;
static UIColor *_deepSleepColor = nil;
static UIColor *_awakeSleepColor = nil;
static UIColor *_tintColor = nil;

+ (void)initialize {
    _tintColor = [UIColor colorWithRed:0 green:0.612 blue:1 alpha:1];
    _warningSensorColor = [UIColor colorWithRed:0.996 green:0.796 blue:0.184 alpha:1];
    _idealSensorColor = [UIColor colorWithRed:0.188 green:0.839 blue:0.671 alpha:1];
    _alertSensorColor = [UIColor colorWithRed:0.992 green:0.592 blue:0.329 alpha:1];
    _lightSleepColor = [UIColor colorWithRed:0.647 green:0.867 blue:1 alpha:1];
    _intermediateSleepColor = [UIColor colorWithRed:0.447 green:0.788 blue:1 alpha:1];
    _deepSleepColor = [UIColor colorWithRed:0 green:0.612 blue:1 alpha:1];
    _awakeSleepColor = [UIColor colorWithRed:0.32 green:0.356 blue:0.8 alpha:0];
    _unknownSensorColor = [UIColor colorWithRed:0.787 green:0.787 blue:0.787 alpha:1];
}

+ (UIColor *)tintColor {
    return _tintColor;
}
+ (UIColor *)warningSensorColor {
    return _warningSensorColor;
}
+ (UIColor *)idealSensorColor {
    return _idealSensorColor;
}
+ (UIColor *)alertSensorColor {
    return _alertSensorColor;
}
+ (UIColor *)unknownSensorColor {
    return _unknownSensorColor;
}
+ (UIColor *)lightSleepColor {
    return _lightSleepColor;
}
+ (UIColor *)intermediateSleepColor {
    return _intermediateSleepColor;
}
+ (UIColor *)deepSleepColor {
    return _deepSleepColor;
}
+ (UIColor *)awakeSleepColor {
    return _awakeSleepColor;
}
+ (UIColor *)currentConditionsBackgroundColor {
    return [UIColor colorWithRed:0.902 green:0.91 blue:0.906 alpha:1];
}
+ (UIColor *)sleepQuestionBgColor {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
}
+ (UIColor *)onboardingGrayColor {
    return [UIColor colorWithRed:0.286 green:0.286 blue:0.286 alpha:1];
}
+ (UIColor *)backViewBackgroundColor {
    return [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
}
+ (UIColor *)backViewNavTitleColor {
    return [UIColor colorWithRed:0.286 green:0.286 blue:0.286 alpha:1];
}
+ (UIColor *)backViewTextColor {
    return [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
}
+ (UIColor *)senseBlueColor {
    return [UIColor colorWithRed:0 green:0.604 blue:1 alpha:1];
}
+ (UIColor *)backViewTintColor {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}
+ (UIColor *)timelineSectionBorderColor {
    return [UIColor colorWithRed:0.9 green:0.91 blue:0.91 alpha:1];
}
+ (UIColor *)timelineGradientDarkColor {
    return [UIColor colorWithRed:0.976 green:0.976 blue:0.976 alpha:1];
}
+ (UIColor *)backViewDetailTextColor {
    return [UIColor colorWithRed:0.631 green:0.631 blue:0.631 alpha:1];
}
+ (UIColor *)barButtonDisabledColor {
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
}
+ (UIColor *)actionViewTitleTextColor {
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
}
+ (UIColor *)actionViewCancelButtonTextColor {
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
}
+ (UIColor *)buttonDividerColor {
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.2];
}
+ (UIColor *)questionAnswerSelectedBgColor {
    return [UIColor colorWithRed:0.961 green:0.984 blue:1 alpha:1];
}
+ (UIColor *)questionAnswerSelectedTextColor {
    return [UIColor colorWithRed:0.804 green:0.91 blue:1 alpha:1];
}
+ (UIColor *)sleepScoreOvalColor {
    return [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
}
+ (UIColor *)tabBarUnselectedColor {
    return [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
}
+ (UIColor *)deviceAlertMessageColor {
    return [UIColor colorWithRed:0.302 green:0.302 blue:0.302 alpha:1];
}
+ (UIColor *)timelineLineColor {
    return [UIColor colorWithRed:0 green:0.617 blue:1 alpha:0.25];
}
+ (UIColor *)timelineInsightTintColor {
    return [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
}
+ (UIColor *)separatorColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.039];
}
+ (UIColor *)onboardingDescriptionColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
}
+ (UIColor *)onboardingTitleColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}
+ (UIColor *)textfieldPlaceholderFocusedColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
}
+ (UIColor *)textfieldPlaceholderColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
}
+ (UIColor *)rulerSegmentDarkColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
}
+ (UIColor *)rulerSegmentLightColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
}
+ (UIColor *)settingsValueTextColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
}
+ (UIColor *)textfieldTextColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
}
+ (UIColor *)actionButtonTextColor {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}
+ (UIColor *)alarmSelectionRowColor {
    return [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
}
+ (UIColor *)pageControlTintColor {
    return [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
}
+ (UIColor *)actionButtonDisabledColor {
    return [UIColor colorWithRed:0.788 green:0.788 blue:0.788 alpha:1];
}
+ (UIColor *)backViewCardShadowColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}
+ (UIColor *)lightTintColor {
    return [UIColor colorWithRed:0.298 green:0.757 blue:0.988 alpha:1];
}
+ (UIColor *)trendTextColor {
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
}
+ (UIColor *)cardBorderColor {
    return [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
}
+ (UIColor *)trendGraphBottomColor {
    return [UIColor colorWithRed:0.95 green:0.97 blue:0.982 alpha:1];
}
+ (UIColor *)trendGraphTopColor {
    return [UIColor colorWithRed:0.913 green:0.966 blue:1 alpha:1];
}
+ (UIColor *)switchOffBackgroundColor {
    return [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
}
+ (UIColor *)buttonContainerShadowColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
}
+ (UIColor *)timelineGradientColor {
    return [UIColor colorWithRed:0.82 green:0.929 blue:1 alpha:1];
}
+ (UIColor *)timelineGradientColor2 {
    return [UIColor colorWithRed:0.886 green:0.953 blue:0.996 alpha:1];
}
+ (UIColor *)tutorialBackgroundColor {
    return [UIColor colorWithRed:0.239 green:0.322 blue:0.4 alpha:0.6];
}
+ (UIColor *)handholdingGestureHintColor {
    return [UIColor colorWithRed:0.004 green:0.612 blue:1 alpha:0.3];
}
+ (UIColor *)handholdingGestureHintBorderColor {
    return [UIColor colorWithRed:0.004 green:0.612 blue:1 alpha:0.8];
}
+ (UIColor *)handholdingMessageBackgroundColor {
    return [UIColor colorWithRed:0.004 green:0.612 blue:1 alpha:1];
}
+ (UIColor *)actionSheetSeparatorColor {
    return [UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1];
}
+ (UIColor *)actionSheetSelectedColor {
    return [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1];
}
+ (UIColor *)timelineBarGradientColor {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.12];
}
+ (UIColor *)timelineBarGradientColor2 {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
}
+ (UIColor *)timelineEventShadowColor {
    return [UIColor colorWithRed:0 green:0.612 blue:1 alpha:1];
}

@end
