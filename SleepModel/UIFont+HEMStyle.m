//
//  UIFont+HEMStyle.m
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "UIFont+HEMStyle.h"

@implementation UIFont (HEMStyle)

static NSString* const HEMFontFamilyName = @"Avenir";
static NSString* const HEMFontFamilyNameBook = @"Avenir-Book";
static NSString* const HEMFontFamilyNameHeavy = @"Avenir-Heavy";
static NSString* const HEMFontFamilyNameLight = @"Avenir-Light";
static NSString* const HEMFontFamilyNameLightOblique = @"Avenir-LightOblique";
static NSString* const HEMFontFamilyNameHeavyOblique = @"Avenir-HeavyOblique";
static NSString* const HEMFontFamilyNameMedium = @"Avenir-Medium";
static NSString* const HEMNumberFontFamilyNameUltraLight = @"AvenirNext-UltraLight";
static NSString* const HEMTitleFontFamilyNameDemiBold = @"AvenirNext-DemiBold";
static NSString* const HEMNumberFontFamilyNameMedium = @"AvenirNext-Medium";

+ (UIFont *)scaledFontWithName:(NSString*)name baseSize:(CGFloat)baseSize {
    static CGFloat const HEMFontBaseScreenWidth = 320.f;
    static CGFloat const HEMFontEnlargedRatio = 1.07f;
    CGFloat factor = 1.f;
    if (CGRectGetWidth([[UIScreen mainScreen] bounds]) > HEMFontBaseScreenWidth)
        factor = HEMFontEnlargedRatio;

    NSInteger fontSize = ceilf(baseSize * factor);
    return [UIFont fontWithName:name size:fontSize];
}

+ (UIFont *)alarmMeridiemFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.f];
}

+ (UIFont *)alarmNumberFont {
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:50.f];
}

+ (UIFont *)insightTitleFont {
    return [UIFont fontWithName:HEMTitleFontFamilyNameDemiBold size:24.f];
}

+ (UIFont *)insightFullMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.f];
}

+ (UIFont *)insightFullMessageBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:16.f];
}

+ (UIFont *)largeNumberFont {
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:72.f];
}

+ (UIFont *)settingsTableCellFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.f];
}

+ (UIFont *)settingsTableCellDetailFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:15.f];
}

+ (UIFont *)settingsTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.f];
}

+ (UIFont *)settingsHelpFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:13.0f];
}

+ (UIFont *)preferenceControlFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont *)sensorRangeSelectionFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:14.f];
}

+ (UIFont *)sensorGraphNumberFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:13.f];
}

+ (UIFont *)sensorGraphNumberBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:13.f];
}

+ (UIFont *)sensorGraphHeadingFont {
    return [UIFont fontWithName:HEMFontFamilyNameBook size:10.f];
}

+ (UIFont *)sensorGraphHeadingBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:10.f];
}

+ (UIFont *)sensorListValueFont {
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:36.f];
}

+ (UIFont *)sensorMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.f];
}


+ (UIFont *)backViewTitleFont {
    return [UIFont scaledFontWithName:HEMFontFamilyNameHeavy baseSize:11.f];
}

+ (UIFont *)backViewTextFont {
    return [UIFont scaledFontWithName:HEMFontFamilyNameLight baseSize:14.f];
}

+ (UIFont *)backViewBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:14.f];
}

+ (UIFont *)timelineBreakdownValueFont {
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:24.f];
}

+ (UIFont *)timelineEventMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.f];
}

+ (UIFont *)timelineEventMessageItalicFont {
    return [UIFont fontWithName:HEMFontFamilyNameLightOblique size:13.f];
}

+ (UIFont *)timelineEventMessageBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:14.f];
}

+ (UIFont *)timelineEventTimestampFont {
    return [UIFont fontWithName:HEMNumberFontFamilyNameMedium size:11.f];
}

+ (UIFont *)timelineEventTimestampBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:13.f];
}

+ (UIFont *)timelineEventTipFont {
    return [UIFont fontWithName:HEMFontFamilyNameLightOblique size:13.f];
}

+ (UIFont *)timelineEventTipBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavyOblique size:13.f];
}

+ (UIFont *)timelineMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.f];
}

+ (UIFont *)timelineMessageBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:14.f];
}

+ (UIFont *)tutorialDialogFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.f];
}

+ (UIFont *)questionAnswerFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:18.0f];
}

+ (UIFont *)questionFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont *)thankyouFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont *)infoToastFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:20.0f];
}

+ (UIFont *)inAppBrowserTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.0f];
}

+ (UIFont *)dialogTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:18.0f];
}

+ (UIFont *)dialogMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:15.0f];
}

+ (UIFont* )primaryButtonFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:16.0f];
}

+ (UIFont* )secondaryButtonFont {
    return [UIFont fontWithName:HEMFontFamilyNameBook size:16.0f];
}

+ (UIFont *)navButtonTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont *)confidentialityWarningFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:11.f];
}

+ (UIFont *)actionViewTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:15.0f];
}

+ (UIFont *)actionViewMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.0f];
}

+ (UIFont *)actionViewButtonTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:18.0f];
}

+ (UIFont*)feedQuestionFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)feedInsightMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:13.0];
}

+ (UIFont*)feedInsightMessageBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:13.0];
}

+ (UIFont*)deviceAlertMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)deviceCellWarningMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:13.0f];
}

+ (UIFont *)textfieldPlaceholderFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont *)textfieldTextFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont *)trendOptionFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:14.f];
}

#pragma mark - Onboarding

+ (UIFont *)onboardingActivityFontLarge {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont *)onboardingActivityFontMedium {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont *)singleComponentPickerViewFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:18.0f];
}

+ (UIFont *)birthdatePickerTextFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.0f];
}

+ (UIFont *)onboardingFieldRightViewFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:16.0f];
}

+ (UIFont *)onboardingTitleFont {
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:24.0f];
}

+ (UIFont *)onboardingTitleLargeFont {
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:32.0f];
}

+ (UIFont *)onboardingDescriptionFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:15.0f];
}

+ (UIFont *)onboardingDescriptionLargeFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont *)onboardingDescriptionBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:14.0f];
}

+ (UIFont*)onboardingRoomCheckSensorFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:15.0f];
}

+ (UIFont*)onboardingRoomCheckSensorValueFont {
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:80.0f];
}

+ (UIFont*)onboardingRoomCheckSensorUnitFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.0f];
}

+ (UIFont*)genderButtonTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.0f];
}

+ (UIFont*)helpButtonTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont*)wifiTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)bluetoothStepsFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.0f];
}

@end
