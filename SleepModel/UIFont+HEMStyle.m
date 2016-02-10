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

static NSString* const HEMFontFamilyNameModernUltraLight = @"AvenirNext-UltraLight";
static NSString* const HEMFontFamilyNameModernRegular = @"AvenirNext-Regular";
static NSString* const HEMFontFamilyNameModernMedium = @"AvenirNext-Medium";
static NSString* const HEMFontFamilyNameModernLight = @"AvenirNext-Light";
static NSString* const HEMFontFamilyNameModernThin = @"AvenirNext-Thin";

static NSString* const HEMNumberFontFamilyNameUltraLight = @"AvenirNext-UltraLight";
static NSString* const HEMTitleFontFamilyNameDemiBold = @"AvenirNext-DemiBold";
static NSString* const HEMNumberFontFamilyNameMedium = @"AvenirNext-Medium";

+ (UIFont*)alarmMeridiemFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.f];
}

+ (UIFont*)alarmNumberFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernThin size:32.f];
}

+ (UIFont*)alarmSelectedNumberFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernThin size:56.f];
}

+ (UIFont*)alarmDetailFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:14.0f];
}

+ (UIFont*)alarmTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernLight size:16.0f];
}

+ (UIFont*)alarmButtonFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:14.f];
}

+ (UIFont*)insightAboutFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:10.f];
}

+ (UIFont*)insightSummaryBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:14.f];
}

+ (UIFont*)insightSummaryFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.f];
}

+ (UIFont*)insightTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:24.f];
}

+ (UIFont*)insightFullMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:16.f];
}

+ (UIFont*)insightFullMessageBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:16.f];
}

+ (UIFont*)insightDismissButtonFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:14.f];
}

+ (UIFont*)largeNumberFont
{
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:72.f];
}

+ (UIFont*)settingsTableCellFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:16.f];
}

+ (UIFont*)settingsTableCellDetailFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernLight size:14.f];
}

+ (UIFont*)settingsTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.f];
}

+ (UIFont*)iPhone4SSettingsTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.f];
}

+ (UIFont *)settingsSectionHeaderFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:10.0f];
}

+ (UIFont*)settingsHelpFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernLight size:14.0f];
}

+ (UIFont*)preferenceControlFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)sensorRangeSelectionFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:14.f];
}

+ (UIFont*)sensorGraphNumberFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:13.f];
}

+ (UIFont*)sensorGraphNumberBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:13.f];
}

+ (UIFont*)sensorGraphNoDataFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernLight size:14.f];
}

+ (UIFont*)sensorGraphHeadingFont
{
    return [UIFont fontWithName:HEMFontFamilyNameBook size:10.f];
}

+ (UIFont*)sensorGraphHeadingBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:10.f];
}

+ (UIFont*)sensorValueFontForUnit:(SENSensorUnit)unit
{
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:72.f];
}

+ (UIFont*)sensorUnitFontForUnit:(SENSensorUnit)unit
{
    switch (unit) {
        case SENSensorUnitAQI:
            return [UIFont fontWithName:HEMFontFamilyNameLight size:22.0f];
        default:
            return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:32.f];
    }
}

+ (UIFont*)sensorListValueFontForUnit:(SENSensorUnit)unit
{
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:36.f];
}

+ (UIFont*)sensorListUnitFontForUnit:(SENSensorUnit)unit
{
    switch (unit) {
        case SENSensorUnitDegreeCentigrade:
            return [UIFont fontWithName:HEMFontFamilyNameLight size:20.0f];
        default:
            return [UIFont fontWithName:HEMFontFamilyNameLight size:16.f];
    }
}

+ (UIFont*)sensorTimestampFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.f];
}

+ (UIFont*)sensorMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.f];
}

+ (UIFont*)sensorMessageBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:16.0f];
}

+ (UIFont*)backViewTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:11.f];
}

+ (UIFont*)backViewTextFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:14.f];
}

+ (UIFont*)backViewBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:14.f];
}

+ (UIFont*)timelineBreakdownTitleFont
{
    return [UIFont fontWithName:HEMNumberFontFamilyNameMedium size:11.f];
}

+ (UIFont*)timelineBreakdownMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.f];
}

+ (UIFont*)timelineBreakdownMessageBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:14.f];
}

+ (UIFont*)timelineBreakdownValueFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.f];
}

+ (UIFont*)timelineTimeLabelFont
{
    return [UIFont fontWithName:HEMFontFamilyNameBook size:11.f];
}

+ (UIFont*)timelineEventMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.f];
}

+ (UIFont*)timelineEventMessageItalicFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLightOblique size:14.f];
}

+ (UIFont*)timelineEventMessageBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:14.f];
}

+ (UIFont*)timelineEventTipFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLightOblique size:13.f];
}

+ (UIFont*)timelineEventTipBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavyOblique size:13.f];
}

+ (UIFont*)timelineMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.f];
}

+ (UIFont*)timelineMessageBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:14.f];
}

+ (UIFont*)timelinePopupFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.f];
}

+ (UIFont*)timelinePopupBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:14.f];
}

+ (UIFont*)questionAnswerFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:18.0f];
}

+ (UIFont*)questionFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont*)thankyouFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont*)inAppBrowserTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.0f];
}

+ (UIFont*)dialogTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:16.0f];
}

+ (UIFont*)dialogMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.0f];
}

+ (UIFont*)dialogMessageBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:15.0f];
}

+ (UIFont*)primaryButtonFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:15.0f];
}

+ (UIFont*)secondaryButtonFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:14.0f];
}

+ (UIFont*)alertBoldButtonFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:16.0f];
}

+ (UIFont*)alertLightButtonFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)navButtonTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)confidentialityWarningFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:11.f];
}

+ (UIFont*)actionViewTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:15.0f];
}

+ (UIFont*)actionViewMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.0f];
}

+ (UIFont*)actionViewButtonTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:18.0f];
}

+ (UIFont*)feedQuestionFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)feedInsightMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:13.0];
}

+ (UIFont*)feedInsightMessageBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:13.0];
}

+ (UIFont*)systemAlertMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)deviceSettingsLabelFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernLight size:16.0f];
}

+ (UIFont*)deviceSettingsPropertyValueFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:16.0f];
}

+ (UIFont*)deviceCellWarningSummaryFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernLight size:14.0f];
}

+ (UIFont*)deviceCellWarningMessageFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:14.0f];
}

+ (UIFont*)textfieldPlaceholderFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)textfieldTextFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)trendsTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:16.0f];
}

+ (UIFont*)trendsScopeSelectorTextFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:12.0f];
}

+ (UIFont*)trendOptionFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:14.f];
}

+ (UIFont*)trendXAxisLabelFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:10.0f];
}

+ (UIFont*)trendsHighlightLabelFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:12.0f];
}

+ (UIFont*)trendBottomLabelFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.f];
}

+ (UIFont*)trendSleepDepthTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:10.f];
}

+ (UIFont*)trendScoreFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:12.0f];
}

+ (UIFont*)trendAverageTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:10.0f];
}

+ (UIFont*)trendAverageValueFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernUltraLight size:28.0f];
}

+ (UIFont*)trendSleepDepthValueFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:HEMFontFamilyNameModernUltraLight size:size];
}

+ (UIFont*)timeZoneNameFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

#pragma mark - Onboarding

+ (UIFont*)welcomeTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernUltraLight size:40.0f];
}

+ (UIFont*)welcomeDescriptionFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:15.0f];
}

+ (UIFont*)welcomeVideoButtonFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:13.0f];
}

+ (UIFont*)welcomeButtonFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernMedium size:14.0f];
}

+ (UIFont*)welcomeIntroTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:20.0f];
}

+ (UIFont*)welcomeIntroDescriptionFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:15.0f];
}

+ (UIFont*)onboardingActivityFontLarge
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont*)onboardingActivityFontMedium
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)singleComponentPickerViewFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:18.0f];
}

+ (UIFont*)birthdatePickerTextFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.0f];
}

+ (UIFont*)onboardingFieldRightViewFont
{
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:16.0f];
}

+ (UIFont*)onboardingTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:20.0f];
}

+ (UIFont*)onboardingTitleLargeFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:28.0f];
}

+ (UIFont*)onboardingDescriptionFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:16.0f];
}

+ (UIFont*)onboardingDescriptionLargeFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:17.0f];
}

+ (UIFont*)onboardingDescriptionBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:16.0f];
}

+ (UIFont*)onboardingRoomCheckSensorLightFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:11.0f];
}

+ (UIFont*)onboardingRoomCheckSensorFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)onboardingRoomCheckSensorBoldFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:16.0f];
}

+ (UIFont*)onboardingRoomCheckSensorValueFont
{
    return [UIFont fontWithName:HEMNumberFontFamilyNameUltraLight size:72.0f];
}

+ (UIFont*)genderButtonTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:20.0f];
}

+ (UIFont*)helpButtonTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:24.0f];
}

+ (UIFont*)wifiTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)bluetoothStepsFont
{
    return [UIFont fontWithName:HEMFontFamilyNameLight size:14.0f];
}

#pragma mark - Action Sheet

+ (UIFont*)actionSheetTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:11.0f];
}

+ (UIFont*)actionSheetOptionTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.0f];
}

+ (UIFont*)actionSheetOptionDescriptionFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:15.0f];
}

+ (UIFont*)actionSheetTitleViewTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:18.0f];
}

+ (UIFont*)actionSheetTitleViewDescriptionFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:15.0f];
}

#pragma mark - Tutorial Dialogs

+ (UIFont*)tutorialTitleFont
{
    return [UIFont fontWithName:HEMFontFamilyNameHeavy size:18.0f];
}

+ (UIFont*)tutorialDescriptionFont
{
    return [UIFont fontWithName:HEMFontFamilyNameBook size:16.0f];

}

+ (UIFont*)handholdingMessageFont {
    return [UIFont fontWithName:HEMFontFamilyNameMedium size:14.0f];
}

#pragma mark - Support

+ (UIFont*)supportTicketDescriptionFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:16.0f];
}

+ (UIFont*)supportHelpCenterFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.0f];
}

#pragma mark - Timeline action sheet confirmation

+ (UIFont*)timelineActionConfirmationTitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:18.0f];
}

+ (UIFont*)timelineActionConfirmationSubtitleFont {
    return [UIFont fontWithName:HEMFontFamilyNameLight size:15.0f];
}

#pragma mark - Empty / Error States

+ (UIFont*)emptyStateDescriptionFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernRegular size:14.0f];
}

+ (UIFont*)errorStateDescriptionFont {
    return [UIFont fontWithName:HEMFontFamilyNameModernLight size:17.0f];
}

@end
