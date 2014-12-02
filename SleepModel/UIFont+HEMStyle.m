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
static NSString* const HEMLargeNumberFontFamilyName = @"AvenirNext-UltraLight";

+ (UIFont *)alarmMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:13.f];
}

+ (UIFont *)alarmMessageBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:13.f];
}

+ (UIFont *)insightTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:10.f];
}

+ (UIFont *)insightCardTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:13.f];
}

+ (UIFont *)insightCardMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.f];
}

+ (UIFont *)largeNumberFont {
    return [UIFont fontWithName:HEMLargeNumberFontFamilyName size:72.f];
}

+ (UIFont *)settingsInsightMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:13.f];
}

+ (UIFont *)settingsTableCellFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.f];
}

+ (UIFont *)settingsTableCellDetailFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.f];
}

+ (UIFont *)settingsTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.f];
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

+ (UIFont *)timelineEventMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:13.f];
}

+ (UIFont *)timelineEventMessageBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:13.f];
}

+ (UIFont *)timelineEventTipFont {
    return [UIFont fontWithName:HEMFontFamilyNameLightOblique size:13.f];
}

+ (UIFont *)timelineEventTipBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavyOblique size:13.f];
}

+ (UIFont *)timelineMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:15.f];
}

+ (UIFont *)timelineMessageBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:15.f];
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

+ (UIFont *)onboardingActivityFontLarge {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont *)onboardingActivityFontMedium {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont *)singleComponentPickerViewFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:18.0f];
}

+ (UIFont *)onboardingFieldRightViewFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:16.0f];
}

+ (UIFont *)onboardingTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont *)onboardingDescriptionFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:17.0f];
}

+ (UIFont *)onboardingDescriptionBoldFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:17.0f];
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
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:14.0f];
}

+ (UIFont* )secondaryButtonFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:12.0f];
}

+ (UIFont *)navButtonTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:17.0f];
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

@end
