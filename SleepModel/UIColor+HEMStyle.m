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
+ (UIColor *)onboardingGrayColor {
    return [UIColor colorWithHex:0x494949 alpha:1.f];
}
+ (UIColor *)backViewBackgroundColor {
    return [UIColor colorWithHex:0xF2F2F2 alpha:1.f];
}
+ (UIColor *)backViewNavTitleColor {
    return [UIColor colorWithHex:0x494949 alpha:1.f];
}
+ (UIColor *)backViewTextColor {
    return [UIColor colorWithHex:0x4D4D4D alpha:1.f];
}
+ (UIColor *)senseBlueColor {
    return [UIColor colorWithHex:0x009AFF alpha:1.f];
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
    return [UIColor colorWithHex:0x000000 alpha:0.039];
}
+ (UIColor *)onboardingDescriptionColor {
    return [UIColor colorWithHex:0x000000 alpha:0.4];
}
+ (UIColor *)onboardingTitleColor {
    return [UIColor colorWithHex:0x000000 alpha:1.f];
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

@end
