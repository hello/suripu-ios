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
            return [self conditionAlertColor];
        case SENConditionWarning:
            return [self conditionWarningColor];
        case SENConditionIdeal:
            return [self conditionIdealColor];
        default:
            return [self conditionUnknownColor];
    }
}

+ (UIColor *)colorForSleepState:(SENTimelineSegmentSleepState)state {
    switch (state) {
        case SENTimelineSegmentSleepStateAwake:
            return [self sleepStateAwakeColor];
        case SENTimelineSegmentSleepStateLight:
            return [self sleepStateLightColor];
        case SENTimelineSegmentSleepStateMedium:
            return [self sleepStateMediumColor];
        case SENTimelineSegmentSleepStateSound:
            return [self sleepStateSoundColor];
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
        return [self conditionUnknownColor];
    else if (score < 50)
        return [self conditionAlertColor];
    else if (score < 80)
        return [self conditionWarningColor];

    return [self conditionIdealColor];
}

#pragma mark - Palette

#pragma mark Cache

static UIColor *_conditionWarningColor = nil;
static UIColor *_conditionIdealColor = nil;
static UIColor *_conditionAlertColor = nil;
static UIColor *_conditionUnknownColor = nil;
static UIColor *_sleepStateLightColor = nil;
static UIColor *_sleepStateMediumColor = nil;
static UIColor *_sleepStateSoundColor = nil;
static UIColor *_sleepStateAwakeColor = nil;
static UIColor *_tintColor = nil;

+ (void)initialize {
    _tintColor = [UIColor colorWithRed:0 green:0.612 blue:1 alpha:1];
    _conditionWarningColor = [UIColor colorWithRed:0.996 green:0.796 blue:0.184 alpha:1];
    _conditionIdealColor = [UIColor colorWithRed:0.188 green:0.839 blue:0.671 alpha:1];
    _conditionAlertColor = [UIColor colorWithRed:0.992 green:0.592 blue:0.329 alpha:1];
    _sleepStateLightColor = [UIColor colorWithRed:0.647 green:0.867 blue:1 alpha:1];
    _sleepStateMediumColor = [UIColor colorWithRed:0.447 green:0.788 blue:1 alpha:1];
    _sleepStateSoundColor = [UIColor colorWithRed:0 green:0.612 blue:1 alpha:1];
    _sleepStateAwakeColor = [UIColor colorWithRed:0.32 green:0.356 blue:0.8 alpha:0];
    _conditionUnknownColor = [UIColor colorWithRed:0.787 green:0.787 blue:0.787 alpha:1];
}

+ (UIColor *)tintColor {
    return _tintColor;
}
+ (UIColor *)conditionWarningColor {
    return _conditionWarningColor;
}
+ (UIColor *)conditionIdealColor {
    return _conditionIdealColor;
}
+ (UIColor *)conditionAlertColor {
    return _conditionAlertColor;
}
+ (UIColor *)conditionUnknownColor {
    return _conditionUnknownColor;
}
+ (UIColor *)sleepStateLightColor {
    return _sleepStateLightColor;
}
+ (UIColor *)sleepStateMediumColor {
    return _sleepStateMediumColor;
}
+ (UIColor *)sleepStateSoundColor {
    return _sleepStateSoundColor;
}
+ (UIColor *)sleepStateAwakeColor {
    return _sleepStateAwakeColor;
}
+ (UIColor *)onboardingGrayColor {
    return [UIColor colorWithHex:0x494949 alpha:1.f];
}
+ (UIColor *)backViewBackgroundColor {
    return [UIColor colorWithHex:0xEBEDF0 alpha:1.f];
}
+ (UIColor *)backViewNavTitleColor {
    return [UIColor colorWithHex:0x494949 alpha:1.f];
}
+ (UIColor *)backViewTextColor {
    return [UIColor colorWithHex:0x4D4D4D alpha:1.f];
}
+ (UIColor *)backViewTintColor {
    return [UIColor whiteColor];
}
+ (UIColor *)barButtonDisabledColor {
    return [UIColor colorWithHex:0x999999 alpha:1.f];
}
+ (UIColor *)actionViewTitleTextColor {
    return [UIColor colorWithHex:0x999999 alpha:1.f];
}
+ (UIColor *)actionViewCancelButtonTextColor {
    return [UIColor colorWithHex:0x999999 alpha:1.f];
}
+ (UIColor *)alertBackgroundColor {
    return [UIColor colorWithHex:0x596980 alpha:0.9];
}
+ (UIColor *)alertBooleanSecondaryColor {
    return [UIColor colorWithHex:0x69788C alpha:0.5];
}
+ (UIColor *)buttonDividerColor {
    return [UIColor colorWithHex:0x999999 alpha:0.2];
}
+ (UIColor *)questionAnswerSelectedBgColor {
    return [UIColor colorWithHex:0xF5FBFF alpha:1.f];
}
+ (UIColor *)questionAnswerSelectedTextColor {
    return [UIColor colorWithHex:0xCDE8FF alpha:1.f];
}
+ (UIColor *)sleepScoreOvalColor {
    return [UIColor colorWithHex:0xE5E5E5 alpha:1.f];
}
+ (UIColor *)deviceAlertMessageColor {
    return [UIColor colorWithHex:0x4D4D4D alpha:1.f];
}
+ (UIColor *)separatorColor {
    return [UIColor colorWithHex:0x000000 alpha:0.05f];
}
+ (UIColor *)onboardingDescriptionColor {
    return [UIColor colorWithHex:0x0B0B0B alpha:0.5f];
}
+ (UIColor *)onboardingTitleColor {
    return [UIColor colorWithHex:0x000000 alpha:0.7f];
}
+ (UIColor *)textfieldPlaceholderFocusedColor {
    return [UIColor colorWithHex:0x000000 alpha:0.25];
}
+ (UIColor *)textfieldPlaceholderColor {
    return [UIColor colorWithHex:0x000000 alpha:0.4];
}
+ (UIColor *)rulerSegmentDarkColor {
    return [UIColor colorWithHex:0x000000 alpha:0.2];
}
+ (UIColor *)rulerSegmentLightColor {
    return [UIColor colorWithHex:0x000000 alpha:0.1];
}
+ (UIColor *)settingsSectionHeaderTextColor {
    return [UIColor colorWithHex:0x000000 alpha:0.4f];
}
+ (UIColor *)settingsCellTitleTextColor {
    return [UIColor colorWithHex:0x000000 alpha:0.7f];
}
+ (UIColor *)settingsValueTextColor {
    return [UIColor colorWithHex:0x000000 alpha:0.4];
}
+ (UIColor *)textfieldTextColor {
    return [UIColor colorWithHex:0x000000 alpha:0.7];
}
+ (UIColor *)actionButtonTextColor {
    return [UIColor whiteColor];
}
+ (UIColor *)alarmSelectionRowColor {
    return [UIColor colorWithHex:0xBFBFBF alpha:1.f];
}
+ (UIColor *)pageControlTintColor {
    return [UIColor colorWithHex:0xEBEBEB alpha:1.f];
}
+ (UIColor *)actionButtonDisabledColor {
    return [UIColor colorWithHex:0xC9C9C9 alpha:1.f];
}
+ (UIColor *)lightTintColor {
    return [UIColor colorWithHex:0x4CC1FC alpha:1.f];
}
+ (UIColor *)trendTextColor {
    return [UIColor colorWithHex:0x999999 alpha:1.f];
}
+ (UIColor *)cardBorderColor {
    return [UIColor colorWithHex:0xE5E5E5 alpha:1.f];
}
+ (UIColor *)trendGraphBottomColor {
    return [UIColor colorWithHex:0xF2F7FA alpha:1.f];
}
+ (UIColor *)trendGraphTopColor {
    return [UIColor colorWithHex:0xE9F6FF alpha:1.f];
}
+ (UIColor *)switchOffBackgroundColor {
    return [UIColor colorWithHex:0xF2F2F2 alpha:1.f];
}
+ (UIColor *)timelineGradientColor {
    return [UIColor colorWithHex:0xD1EDFF alpha:1.f];
}
+ (UIColor *)tutorialBackgroundColor {
    return [UIColor colorWithHex:0x3D5266 alpha:0.6];
}
+ (UIColor *)handholdingGestureHintColor {
    return [UIColor colorWithHex:0x019CFF alpha:0.3];
}
+ (UIColor *)handholdingGestureHintBorderColor {
    return [UIColor colorWithHex:0x019CFF alpha:0.8];
}
+ (UIColor *)handholdingMessageBackgroundColor {
    return [UIColor colorWithHex:0x019CFF alpha:1.f];
}
+ (UIColor *)actionSheetSeparatorColor {
    return [UIColor colorWithHex:0xE1E1E1 alpha:1.f];
}
+ (UIColor *)actionSheetSelectedColor {
    return [UIColor colorWithHex:0xF7F7F7 alpha:1.f];
}
+ (UIColor *)timelineSelectedBackgroundColor {
    return [UIColor colorWithHex:0xEBF7FF alpha:1.f];
}
+ (UIColor *)timelineAccentColor {
    return [UIColor colorWithHex:0xFF9922 alpha:1.f];
}
+ (UIColor *)timelineWaveformColor {
    return [UIColor colorWithHex:0xCCD3DB alpha:1.f];
}
+ (UIColor *)welcomeTitleColor {
    return [UIColor colorWithHex:0x000000 alpha:1.0f];
}
+ (UIColor *)welcomeDescriptionColor {
    return [UIColor colorWithHex:0x0B0B0B alpha:0.5f];
}
+ (UIColor *)welcomeVideoButtonColor {
    return [UIColor colorWithHex:0x0B0B0B alpha:0.4f];
}
+ (UIColor *)welcomeIntroTitleColor {
    return [UIColor colorWithHex:0x000000 alpha:0.7f];
}
+ (UIColor *)welcomeIntroDescriptionColor {
    return [UIColor colorWithHex:0x000000 alpha:0.7f];
}
+ (UIColor *)emptyStateDescriptionColor {
    return [UIColor colorWithHex:0x000000 alpha:0.5f];
}
+ (UIColor *)sensorGraphNoDataColor {
    return [UIColor colorWithHex:0x000000 alpha:0.5f];
}
+ (UIColor *)backgroundColorForRemoteImageView {
    return [UIColor colorWithHex:0xDFE1E6 alpha:1.0f];
}
+ (NSArray *)timelineSelectedGradientColorRefs {
    // if you change the values, you should check the references to ensure the
    // locations matches the colors
    return @[(id)[UIColor colorWithHex:0xF5F7FA alpha:1.f].CGColor,
             (id)[UIColor colorWithHex:0xF5F7FA alpha:0.f].CGColor];
}
+ (NSArray*)roomCheckValueGradientColorRefs {
    // if you change the values, you should check the references to ensure the
    // locations matches the colors
    return @[(id)[UIColor whiteColor].CGColor,
             (id)[UIColor colorWithWhite:1.0f alpha:0.3f].CGColor];
}

@end
