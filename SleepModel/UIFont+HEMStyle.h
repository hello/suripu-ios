//
//  UIFont+HEMStyle.h
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSensor.h>
#import <UIKit/UIKit.h>

@interface UIFont (HEMStyle)

#pragma mark - Style guide

+ (UIFont*)h1;
+ (UIFont*)h2;
+ (UIFont*)h3;
+ (UIFont*)h4;
+ (UIFont*)h5;
+ (UIFont*)h6;
+ (UIFont*)h7;
+ (UIFont*)h7Bold;
+ (UIFont*)h8;
+ (UIFont*)body;
+ (UIFont*)bodyBold;
+ (UIFont*)bodySmall;
+ (UIFont*)bodySmallBold;
+ (UIFont*)button;

#pragma mark - Common fonts

/**
 *  Font for settings table cell titles
 */
+ (UIFont*)settingsTableCellFont;

/**
 *  Font for settings detail items, like sensor value and next alarm time
 */
+ (UIFont*)settingsTableCellDetailFont;

#pragma mark -

/**
 *  Alarm picker view selected number font
 */
+ (UIFont*)alarmNumberFont;

+ (UIFont*)alarmSelectedNumberFont;
+ (UIFont*)alarmDetailFont;
+ (UIFont*)alarmTitleFont;

/**
 * Font for Alarm UI's cancel and save buttons
 */
+ (UIFont*)alarmButtonFont;

/**
 *  Alarm picker view meridiem font
 */
+ (UIFont*)alarmMeridiemFont;

/**
 *  Font for insight about text in the detail screen
 */
+ (UIFont*)insightAboutFont;

/**
 *  Font for insight detail summary text that is in bold
 */
+ (UIFont*)insightSummaryBoldFont;

/**
 *  Font for section and insight headings
 */
+ (UIFont*)insightTitleFont;

/**
 * Font for the message displayed on insight full view
 */
+ (UIFont*)insightFullMessageFont;

/**
 * Font for the bold message displayed on insight full view
 */
+ (UIFont*)insightFullMessageBoldFont;

/**
 * Font for the close button inside an insight
 */
+ (UIFont*)insightDismissButtonFont;

/**
 *  Font for current sensor value and sleep score
 */
+ (UIFont*)largeNumberFont;

/**
 *  Navigation item title font
 */
+ (UIFont*)settingsTitleFont;

+ (UIFont*)iPhone4SSettingsTitleFont;

+ (UIFont *)settingsSectionHeaderFont;

/**
 * Font used for the help text in settings
 */
+ (UIFont*)settingsHelpFont;

/**
 * Font used for the toggle switches found in preference settings
 */
+ (UIFont*)preferenceControlFont;

+ (UIFont*)sensorValueFontForUnit:(SENSensorUnit)unit;

+ (UIFont*)sensorListValueFontForUnit:(SENSensorUnit)unit;

+ (UIFont*)sensorUnitFontForUnit:(SENSensorUnit)unit;

+ (UIFont*)sensorListUnitFontForUnit:(SENSensorUnit)unit;

+ (UIFont*)backViewTextFont;

+ (UIFont*)backViewBoldFont;

+ (UIFont*)backViewTitleFont;

+ (UIFont*)sensorTimestampFont;

+ (UIFont*)sensorMessageFont;

+ (UIFont*)sensorMessageBoldFont;

+ (UIFont*)timelinePopupFont;

+ (UIFont*)timelinePopupBoldFont;

/**
 *  Font for sensor range selection from 'last 24 hours' and
 *  'last week'
 */
+ (UIFont*)sensorRangeSelectionFont;

/**
 *  Font for numbers at the bottom of each graph section
 */
+ (UIFont*)sensorGraphNumberFont;

/**
 *  Bold font for numbers
 */
+ (UIFont*)sensorGraphNumberBoldFont;

/**
 *  Sensor history graph's no data label (loading as well)
 */
+ (UIFont*)sensorGraphNoDataFont;

/**
 *  Font for headings at the top of each graph section
 */
+ (UIFont*)sensorGraphHeadingFont;

/**
 *  Bold font for headings at the top of each graph section
 */
+ (UIFont*)sensorGraphHeadingBoldFont;

/**
 *  Font for event message text in the timeline
 */
+ (UIFont*)timelineEventMessageFont;

/**
 *  Font for event message _italic_ text in the timeline
 */
+ (UIFont*)timelineEventMessageItalicFont;

/**
 *  Bold font for event message text in the timeline
 */
+ (UIFont*)timelineEventMessageBoldFont;

/**
 *  Font for timeline statistics titles
 */
+ (UIFont*)timelineBreakdownTitleFont;

/**
 *  Font for timeline statistics message summary
 */
+ (UIFont*)timelineBreakdownMessageFont;
+ (UIFont*)timelineBreakdownMessageBoldFont;

/**
 *  Font for timeline statistics values
 */
+ (UIFont*)timelineBreakdownValueFont;

/**
 *  Font for inline labels indicating event time
 */
+ (UIFont*)timelineTimeLabelFont;

/**
 *  Font for tips at the bottom of event expansion
 */
+ (UIFont*)timelineEventTipFont;

/**
 *  Bold font for tips at the bottom of event expansion
 */
+ (UIFont*)timelineEventTipBoldFont;

/**
 *  Font for summary text above the timeline
 */
+ (UIFont*)timelineMessageFont;

/**
 *  Bold font for summary text above the timeline
 */
+ (UIFont*)timelineMessageBoldFont;

/**
 *  Font used to display average titles in Trends v2
 */
+ (UIFont*)trendAverageTitleFont;

/**
 *  Font used to display average values in Trends v2
 */
+ (UIFont*)trendAverageValueFont;

/**
 *  Font used to display the 'h' in averages for trends v2
 */
+ (UIFont*)trendAverageValueHourFont;

/**
 *  Font for the v2 Trends scope selector text
 */
+ (UIFont*)subNavTitleTextFont;

/**
 *  Font for the v2 Trends sleep depth percentage values
 */
+ (UIFont*)trendSleepDepthValueFontWithSize:(CGFloat)size;

/**
 *  Font used for v2 Trends x axis title labels
 */
+ (UIFont*)trendSubtitleLabelFont;

/**
 *  Font used for v2 trends highlilght labels
 */
+ (UIFont*)trendsHighlightLabelFont;

/**
 *  Font for time scopes in trends view
 */
+ (UIFont*)trendOptionFont;

/**
 *  Font for the footer labels in trend graphs
 */
+ (UIFont*)trendBottomLabelFont;

/**
 *  Font for the sleep depth titles
 */
+ (UIFont*)trendSleepDepthTitleFont;

/**
 *  Font for the sleep scores in trends v2
 */
+ (UIFont*)trendScoreFont;

/**
 *  Font to display the answers for questions
 */
+ (UIFont*)questionAnswerFont;

/**
 *  Font for actual question
 */
+ (UIFont*)questionFont;

/**
 *  Font for display any Thank You text
 */
+ (UIFont*)thankyouFont;

/**
 * Font to be used in a UIPIckerView that has 1 component
 */
+ (UIFont*)singleComponentPickerViewFont;

/**
 * Font to be used to display the in-app browser title
 */
+ (UIFont*)inAppBrowserTitleFont;

/**
 * Font to be used to display the title of a dialog
 */
+ (UIFont*)dialogTitleFont;

/**
 * Font to be used to display the message of a dialog
 */
+ (UIFont*)dialogMessageFont;

/**
 * Font to be used to display the message of a dialog in bold
 */
+ (UIFont*)dialogMessageBoldFont;

/**
 * Font used for normal UIButtons that should be the focus of the screen
 */
+ (UIFont*)primaryButtonFont;

+ (UIFont*)alertBoldButtonFont;

/**
 * Font used for normal UIButtons that are secondary actions
 */
+ (UIFont*)secondaryButtonFont;

+ (UIFont*)alertLightButtonFont;

/**
 * Font to be used with buttons on the navigation bar
 */
+ (UIFont*)navButtonTitleFont;

+ (UIFont*)confidentialityWarningFont;

/**
 * Font for the title of the action alert view
 */
+ (UIFont*)actionViewTitleFont;

/**
 * Font for the message of the action alert view
 */
+ (UIFont*)actionViewMessageFont;

/**
 * Font used to display the question inside the insight feed tab
 */
+ (UIFont*)feedQuestionFont;

/**
 * Font used to display the insight message inside the insight feed tab
 */
+ (UIFont*)feedInsightMessageFont;

/**
 * Font used to display the insight message with bold font inside the insight feed tab
 */
+ (UIFont*)feedInsightMessageBoldFont;

/**
 * Font used to display the system alert message
 */
+ (UIFont*)systemAlertMessageFont;

/**
 * Font used to display a warning summary for the device in a collection view cell
 */
+ (UIFont*)deviceCellWarningSummaryFont;

/**
 * Font used to display a warning message for the device in a collection view cell
 */
+ (UIFont*)deviceCellWarningMessageFont;

/**
 * Font used for the placeholder text within an UITextField
 */
+ (UIFont*)textfieldPlaceholderFont;

/**
 * Font used for the text to display TimeZone names
 */
+ (UIFont*)timeZoneNameFont;

#pragma mark - Onboarding

/**
 * Font used for the title on the very first screen shown when user has not been
 * authenticated
 */
+ (UIFont*)welcomeTitleFont;

/**
 * Font used for the description on the very first screen shown when user has not
 * been authenticated
 */
+ (UIFont*)welcomeDescriptionFont;

/**
 * Font used for the video button on the very first screen shown when user has not
 * been authenticated
 */
+ (UIFont*)welcomeVideoButtonFont;

/**
 * Font used for the buttons on the very first screen shown when user has not
 * been authenticated
 */
+ (UIFont*)welcomeButtonFont;

/**
 * Font used for the title of the intro sections on the very first screen shown
 * when user has not been authenticated
 */
+ (UIFont*)welcomeIntroTitleFont;

/**
 * Font used for the description of the intro sections on the very first screen shown
 * when user has not been authenticated
 */
+ (UIFont*)welcomeIntroDescriptionFont;

/**
 * Font used for the light, checking ..., message in room check
 */
+ (UIFont*)onboardingRoomCheckSensorLightFont;

/**
 * Font for the sensor check view during onboarding's room check
 */
+ (UIFont*)onboardingRoomCheckSensorFont;

/**
 * Font for the sensor check view during onboarding's room check to be applied
 * to strong / emphasized markdown in the message
 */
+ (UIFont*)onboardingRoomCheckSensorBoldFont;

/**
 * Font for the sensor value within the sensor check view during onboarding's
 * room check screen
 */
+ (UIFont*)onboardingRoomCheckSensorValueFont;

/**
 * Font used to display activity status full screen
 */
+ (UIFont*)onboardingActivityFontLarge;

/**
 * Font used to display activity status within another view, typically
 */
+ (UIFont*)onboardingActivityFontMedium;

/**
 * Font to be used for a selected value in the right view of a UITextField during
 * onboarding.  Example use would be the selected security type of wifi
 */
+ (UIFont*)onboardingFieldRightViewFont;

/**
 * Font used to diplay scanned wifi ssids
 */
+ (UIFont*)wifiTitleFont;

/**
 * Font used to display the steps to turn on bluetooth in onboarding
 */
+ (UIFont*)bluetoothStepsFont;

#pragma mark - Action Sheet

/**
 * Font used to display the optional title in the custom action sheet
 */
+ (UIFont*)actionSheetTitleFont;

/**
 * Font used to display the option title in the custom action sheet
 */
+ (UIFont*)actionSheetOptionTitleFont;

/**
 * Font used to display the option description in the custom action sheet
 */
+ (UIFont*)actionSheetOptionDescriptionFont;

/**
 * Font used for the basic custom title view's title, intended to be used with the
 * action sheet
 */
+ (UIFont*)actionSheetTitleViewTitleFont;

/**
 * Font used for the basic custom title view's description, intended to be used 
 * with the action sheet
 */
+ (UIFont*)actionSheetTitleViewDescriptionFont;

#pragma mark - Tutorial Dialogs

/**
 * Font used to display a tutorial's title
 */
+ (UIFont*)tutorialTitleFont;

/**
 * Font used to display a tutorial's content / description
 */
+ (UIFont*)tutorialDescriptionFont;

/**
 * Font used to display a handholding message
 */
+ (UIFont*)handholdingMessageFont;

#pragma mark - Support

/**
 * Font used for the description input in a support ticket form
 */
+ (UIFont*)supportTicketDescriptionFont;

/**
 * Font used to display the Help Center font, minus the actual article
 */
+ (UIFont*)supportHelpCenterFont;

#pragma mark - Timeline action sheet confirmation

/**
 * Font used to display the timeline event adjustment confirmation title
 * within an action sheet
 */
+ (UIFont*)timelineActionConfirmationTitleFont;

/**
 * Font used to display the timeline event adjustment confirmation subtitle
 * within an action sheet
 */
+ (UIFont*)timelineActionConfirmationSubtitleFont;

#pragma mark - Partial data states

/**
 * Font used to display the title for partial data states
 */
+ (UIFont*)partialDataMessageFont;

/**
 * Font used to display the message for partial data states
 */
+ (UIFont*)partialDataTitleFont;

#pragma mark - Empty state font

/**
 * Font used for the text in the empty state views
 * @deprecated use partialDataMessageFont instead
 */
+ (UIFont*)emptyStateDescriptionFont;

/**
 * Font used for text displayed when there was a problem retrieving data to load
 */
+ (UIFont*)errorStateDescriptionFont;

#pragma mark - List Items

/**
 * Font used by the List Item Presenter when configuring list item cells
 */
+ (UIFont*)listItemTitleFont;

#pragma mark - Common card fonts

/**
 * Font used in the title on a card.  See Trends or Sleep Sounds
 */
+ (UIFont*)cardTitleFont;

#pragma mark - Audio Preview Button

/**
 * Font used for the audio preview button for sleep sounds and alarm tones.
 */
+ (UIFont*)audioPreviewButtonTitleFont;

@end
