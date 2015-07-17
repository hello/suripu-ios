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

static UIColor *_currentConditionsBackgroundColor = nil;
static UIColor *_warningSensorColor = nil;
static UIColor *_idealSensorColor = nil;
static UIColor *_alertSensorColor = nil;
static UIColor *_lightSleepColor = nil;
static UIColor *_intermediateSleepColor = nil;
static UIColor *_deepSleepColor = nil;
static UIColor *_awakeSleepColor = nil;
static UIColor *_sleepQuestionBgColor = nil;
static UIColor *_onboardingGrayColor = nil;
static UIColor *_backViewBackgroundColor = nil;
static UIColor *_backViewNavTitleColor = nil;
static UIColor *_backViewTextColor = nil;
static UIColor *_senseBlueColor = nil;
static UIColor *_backViewTintColor = nil;
static UIColor *_timelineSectionBorderColor = nil;
static UIColor *_timelineGradientDarkColor = nil;
static UIColor *_backViewDetailTextColor = nil;
static UIColor *_tintColor = nil;
static UIColor *_barButtonDisabledColor = nil;
static UIColor *_actionViewTitleTextColor = nil;
static UIColor *_actionViewCancelButtonTextColor = nil;
static UIColor *_buttonDividerColor = nil;
static UIColor *_questionAnswerSelectedBgColor = nil;
static UIColor *_questionAnswerSelectedTextColor = nil;
static UIColor *_sleepScoreOvalColor = nil;
static UIColor *_tabBarUnselectedColor = nil;
static UIColor *_deviceAlertMessageColor = nil;
static UIColor *_timelineLineColor = nil;
static UIColor *_timelineInsightTintColor = nil;
static UIColor *_separatorColor = nil;
static UIColor *_onboardingDescriptionColor = nil;
static UIColor *_onboardingTitleColor = nil;
static UIColor *_textfieldPlaceholderFocusedColor = nil;
static UIColor *_textfieldPlaceholderColor = nil;
static UIColor *_rulerSegmentDarkColor = nil;
static UIColor *_rulerSegmentLightColor = nil;
static UIColor *_settingsValueTextColor = nil;
static UIColor *_textfieldTextColor = nil;
static UIColor *_unknownSensorColor = nil;
static UIColor *_actionButtonTextColor = nil;
static UIColor *_alarmSelectionRowColor = nil;
static UIColor *_pageControlTintColor = nil;
static UIColor *_actionButtonDisabledColor = nil;
static UIColor *_backViewCardShadowColor = nil;
static UIColor *_lightTintColor = nil;
static UIColor *_trendTextColor = nil;
static UIColor *_cardBorderColor = nil;
static UIColor *_trendGraphBottomColor = nil;
static UIColor *_trendGraphTopColor = nil;
static UIColor *_switchOffBackgroundColor = nil;
static UIColor *_buttonContainerShadowColor = nil;
static UIColor *_timelineGradientColor = nil;
static UIColor *_timelineGradientColor2 = nil;
static UIColor *_tutorialBackgroundColor = nil;
static UIColor *_handholdingGestureHintColor = nil;
static UIColor *_handholdingGestureHintBorderColor = nil;
static UIColor *_handholdingMessageBackgroundColor = nil;
static UIColor *_actionSheetSeparatorColor = nil;
static UIColor *_actionSheetSelectedColor = nil;
static UIColor *_timelineBarGradientColor = nil;
static UIColor *_timelineBarGradientColor2 = nil;
static UIColor *_timelineEventShadowColor = nil;

+ (void)initialize {
    _currentConditionsBackgroundColor = [UIColor colorWithRed:0.902 green:0.91 blue:0.906 alpha:1];
    _warningSensorColor = [UIColor colorWithRed:0.996 green:0.796 blue:0.184 alpha:1];
    _idealSensorColor = [UIColor colorWithRed:0.188 green:0.839 blue:0.671 alpha:1];
    _alertSensorColor = [UIColor colorWithRed:0.992 green:0.592 blue:0.329 alpha:1];
    _lightSleepColor = [UIColor colorWithRed:0.647 green:0.867 blue:1 alpha:1];
    _intermediateSleepColor = [UIColor colorWithRed:0.447 green:0.788 blue:1 alpha:1];
    _deepSleepColor = [UIColor colorWithRed:0 green:0.612 blue:1 alpha:1];
    _awakeSleepColor = [UIColor colorWithRed:0.32 green:0.356 blue:0.8 alpha:0];
    _sleepQuestionBgColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
    _onboardingGrayColor = [UIColor colorWithRed:0.286 green:0.286 blue:0.286 alpha:1];
    _backViewBackgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    _backViewNavTitleColor = [UIColor colorWithRed:0.286 green:0.286 blue:0.286 alpha:1];
    _backViewTextColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    _senseBlueColor = [UIColor colorWithRed:0 green:0.604 blue:1 alpha:1];
    _backViewTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    _timelineSectionBorderColor = [UIColor colorWithRed:0.9 green:0.91 blue:0.91 alpha:1];
    _timelineGradientDarkColor = [UIColor colorWithRed:0.976 green:0.976 blue:0.976 alpha:1];
    _backViewDetailTextColor = [UIColor colorWithRed:0.631 green:0.631 blue:0.631 alpha:1];
    _tintColor = [UIColor colorWithRed:0 green:0.612 blue:1 alpha:1];
    _barButtonDisabledColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    _actionViewTitleTextColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    _actionViewCancelButtonTextColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    _buttonDividerColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.2];
    _questionAnswerSelectedBgColor = [UIColor colorWithRed:0.961 green:0.984 blue:1 alpha:1];
    _questionAnswerSelectedTextColor = [UIColor colorWithRed:0.804 green:0.91 blue:1 alpha:1];
    _sleepScoreOvalColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    _tabBarUnselectedColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    _deviceAlertMessageColor = [UIColor colorWithRed:0.302 green:0.302 blue:0.302 alpha:1];
    _timelineLineColor = [UIColor colorWithRed:0 green:0.617 blue:1 alpha:0.25];
    _timelineInsightTintColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    _separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.039];
    _onboardingDescriptionColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    _onboardingTitleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    _textfieldPlaceholderFocusedColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    _textfieldPlaceholderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    _rulerSegmentDarkColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    _rulerSegmentLightColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    _settingsValueTextColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    _textfieldTextColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    _unknownSensorColor = [UIColor colorWithRed:0.787 green:0.787 blue:0.787 alpha:1];
    _actionButtonTextColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    _alarmSelectionRowColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    _pageControlTintColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    _actionButtonDisabledColor = [UIColor colorWithRed:0.788 green:0.788 blue:0.788 alpha:1];
    _backViewCardShadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    _lightTintColor = [UIColor colorWithRed:0.298 green:0.757 blue:0.988 alpha:1];
    _trendTextColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    _cardBorderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    _trendGraphBottomColor = [UIColor colorWithRed:0.95 green:0.97 blue:0.982 alpha:1];
    _trendGraphTopColor = [UIColor colorWithRed:0.913 green:0.966 blue:1 alpha:1];
    _switchOffBackgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    _buttonContainerShadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    _timelineGradientColor = [UIColor colorWithRed:0.82 green:0.929 blue:1 alpha:1];
    _timelineGradientColor2 = [UIColor colorWithRed:0.886 green:0.953 blue:0.996 alpha:1];
    _tutorialBackgroundColor = [UIColor colorWithRed:0.239 green:0.322 blue:0.4 alpha:0.6];
    _handholdingGestureHintColor = [UIColor colorWithRed:0.004 green:0.612 blue:1 alpha:0.3];
    _handholdingGestureHintBorderColor = [UIColor colorWithRed:0.004 green:0.612 blue:1 alpha:0.8];
    _handholdingMessageBackgroundColor = [UIColor colorWithRed:0.004 green:0.612 blue:1 alpha:1];
    _actionSheetSeparatorColor = [UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1];
    _actionSheetSelectedColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1];
    _timelineBarGradientColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.12];
    _timelineBarGradientColor2 = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    _timelineEventShadowColor = [UIColor colorWithRed:0 green:0.612 blue:1 alpha:1];
}

+ (UIColor *)currentConditionsBackgroundColor {
    return _currentConditionsBackgroundColor;
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
+ (UIColor *)sleepQuestionBgColor {
    return _sleepQuestionBgColor;
}
+ (UIColor *)onboardingGrayColor {
    return _onboardingGrayColor;
}
+ (UIColor *)backViewBackgroundColor {
    return _backViewBackgroundColor;
}
+ (UIColor *)backViewNavTitleColor {
    return _backViewNavTitleColor;
}
+ (UIColor *)backViewTextColor {
    return _backViewTextColor;
}
+ (UIColor *)senseBlueColor {
    return _senseBlueColor;
}
+ (UIColor *)backViewTintColor {
    return _backViewTintColor;
}
+ (UIColor *)timelineSectionBorderColor {
    return _timelineSectionBorderColor;
}
+ (UIColor *)timelineGradientDarkColor {
    return _timelineGradientDarkColor;
}
+ (UIColor *)backViewDetailTextColor {
    return _backViewDetailTextColor;
}
+ (UIColor *)tintColor {
    return _tintColor;
}
+ (UIColor *)barButtonDisabledColor {
    return _barButtonDisabledColor;
}
+ (UIColor *)actionViewTitleTextColor {
    return _actionViewTitleTextColor;
}
+ (UIColor *)actionViewCancelButtonTextColor {
    return _actionViewCancelButtonTextColor;
}
+ (UIColor *)buttonDividerColor {
    return _buttonDividerColor;
}
+ (UIColor *)questionAnswerSelectedBgColor {
    return _questionAnswerSelectedBgColor;
}
+ (UIColor *)questionAnswerSelectedTextColor {
    return _questionAnswerSelectedTextColor;
}
+ (UIColor *)sleepScoreOvalColor {
    return _sleepScoreOvalColor;
}
+ (UIColor *)tabBarUnselectedColor {
    return _tabBarUnselectedColor;
}
+ (UIColor *)deviceAlertMessageColor {
    return _deviceAlertMessageColor;
}
+ (UIColor *)timelineLineColor {
    return _timelineLineColor;
}
+ (UIColor *)timelineInsightTintColor {
    return _timelineInsightTintColor;
}
+ (UIColor *)separatorColor {
    return _separatorColor;
}
+ (UIColor *)onboardingDescriptionColor {
    return _onboardingDescriptionColor;
}
+ (UIColor *)onboardingTitleColor {
    return _onboardingTitleColor;
}
+ (UIColor *)textfieldPlaceholderFocusedColor {
    return _textfieldPlaceholderFocusedColor;
}
+ (UIColor *)textfieldPlaceholderColor {
    return _textfieldPlaceholderColor;
}
+ (UIColor *)rulerSegmentDarkColor {
    return _rulerSegmentDarkColor;
}
+ (UIColor *)rulerSegmentLightColor {
    return _rulerSegmentLightColor;
}
+ (UIColor *)settingsValueTextColor {
    return _settingsValueTextColor;
}
+ (UIColor *)textfieldTextColor {
    return _textfieldTextColor;
}
+ (UIColor *)unknownSensorColor {
    return _unknownSensorColor;
}
+ (UIColor *)actionButtonTextColor {
    return _actionButtonTextColor;
}
+ (UIColor *)alarmSelectionRowColor {
    return _alarmSelectionRowColor;
}
+ (UIColor *)pageControlTintColor {
    return _pageControlTintColor;
}
+ (UIColor *)actionButtonDisabledColor {
    return _actionButtonDisabledColor;
}
+ (UIColor *)backViewCardShadowColor {
    return _backViewCardShadowColor;
}
+ (UIColor *)lightTintColor {
    return _lightTintColor;
}
+ (UIColor *)trendTextColor {
    return _trendTextColor;
}
+ (UIColor *)cardBorderColor {
    return _cardBorderColor;
}
+ (UIColor *)trendGraphBottomColor {
    return _trendGraphBottomColor;
}
+ (UIColor *)trendGraphTopColor {
    return _trendGraphTopColor;
}
+ (UIColor *)switchOffBackgroundColor {
    return _switchOffBackgroundColor;
}
+ (UIColor *)buttonContainerShadowColor {
    return _buttonContainerShadowColor;
}
+ (UIColor *)timelineGradientColor {
    return _timelineGradientColor;
}
+ (UIColor *)timelineGradientColor2 {
    return _timelineGradientColor2;
}
+ (UIColor *)tutorialBackgroundColor {
    return _tutorialBackgroundColor;
}
+ (UIColor *)handholdingGestureHintColor {
    return _handholdingGestureHintColor;
}
+ (UIColor *)handholdingGestureHintBorderColor {
    return _handholdingGestureHintBorderColor;
}
+ (UIColor *)handholdingMessageBackgroundColor {
    return _handholdingMessageBackgroundColor;
}
+ (UIColor *)actionSheetSeparatorColor {
    return _actionSheetSeparatorColor;
}
+ (UIColor *)actionSheetSelectedColor {
    return _actionSheetSelectedColor;
}
+ (UIColor *)timelineBarGradientColor {
    return _timelineBarGradientColor;
}
+ (UIColor *)timelineBarGradientColor2 {
    return _timelineBarGradientColor2;
}
+ (UIColor *)timelineEventShadowColor {
    return _timelineEventShadowColor;
}

@end
