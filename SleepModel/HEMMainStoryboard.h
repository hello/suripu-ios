//
// HEMMainStoryboard.h
// Copyright (c) 2016 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMMainStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)alarmSwitchCellReuseIdentifier;
+(NSString *)alarmSoundCellReuseIdentifier;
+(NSString *)alarmRepeatCellReuseIdentifier;
+(NSString *)alarmDeleteCellReuseIdentifier;
+(NSString *)singleReuseIdentifier;
+(NSString *)multipleReuseIdentifier;
+(NSString *)preferenceReuseIdentifier;
+(NSString *)imageReuseIdentifier;
+(NSString *)summaryReuseIdentifier;
+(NSString *)titleReuseIdentifier;
+(NSString *)loadingReuseIdentifier;
+(NSString *)detailReuseIdentifier;
+(NSString *)aboutReuseIdentifier;
+(NSString *)optionReuseIdentifier;
+(NSString *)infoCellReuseIdentifier;
+(NSString *)infoReuseIdentifier;
+(NSString *)explanationReuseIdentifier;
+(NSString *)signoutReuseIdentifier;
+(NSString *)unitCellReuseIdentifier;
+(NSString *)settingsCellReuseIdentifier;
+(NSString *)pairReuseIdentifier;
+(NSString *)deviceReuseIdentifier;
+(NSString *)supportCellReuseIdentifier;
+(NSString *)topicCellReuseIdentifier;
+(NSString *)warningReuseIdentifier;
+(NSString *)actionReuseIdentifier;
+(NSString *)connectionReuseIdentifier;
+(NSString *)timezoneReuseIdentifier;
+(NSString *)alarmListCellReuseIdentifier;
+(NSString *)alarmListEmptyCellReuseIdentifier;
+(NSString *)alarmListStatusCellReuseIdentifier;
+(NSString *)alarmChoiceCellReuseIdentifier;
+(NSString *)sensorGraphCellReuseIdentifier;
+(NSString *)errorReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)questionReuseIdentifier;
+(NSString *)insightReuseIdentifier;
+(NSString *)settingsReuseIdentifier;
+(NSString *)calendarReuseIdentifier;
+(NSString *)barReuseIdentifier;
+(NSString *)bubblesReuseIdentifier;
+(NSString *)messageReuseIdentifier;
+(NSString *)summaryViewCellReuseIdentifier;
+(NSString *)breakdownLineCellReuseIdentifier;
+(NSString *)fieldCellReuseIdentifier;

/** Segue Identifiers */
+(NSString *)accountSettingsSegueIdentifier;
+(NSString *)alarmRepeatSegueIdentifier;
+(NSString *)alarmsSegueIdentifier;
+(NSString *)devicesSettingsSegueIdentifier;
+(NSString *)notificationSettingsSegueIdentifier;
+(NSString *)pickSoundSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)senseSegueIdentifier;
+(NSString *)settingsToSupportSegueIdentifier;
+(NSString *)sleepSoundsSegueIdentifier;
+(NSString *)timezoneSegueIdentifier;
+(NSString *)topicsSegueIdentifier;
+(NSString *)unitsSettingsSegueIdentifier;
+(NSString *)updateAccountInfoSegueIdentifier;

/** View Controllers */
+(id)instantiateRootViewController;
+(id)instantiateActionSheetViewController;
+(id)instantiateAlarmListNavViewController;
+(id)instantiateAlarmListViewController;
+(id)instantiateAlarmNavController;
+(id)instantiateAlarmRepeatTableViewController;
+(id)instantiateAlarmViewController;
+(id)instantiateBreakdownController;
+(id)instantiateCurrentNavController;
+(id)instantiateFormViewController;
+(id)instantiateInfoNavigationController;
+(id)instantiateInfoViewController;
+(id)instantiateInsightFeedViewController;
+(id)instantiateSensorViewController;
+(id)instantiateSettingsController;
+(id)instantiateSettingsNavController;
+(id)instantiateSleepGraphController;
+(id)instantiateSleepHistoryController;
+(id)instantiateSleepInsightViewController;
+(id)instantiateSleepQuestionsViewController;
+(id)instantiateSleepSoundViewController;
+(id)instantiateSoundsContainerViewController;
+(id)instantiateSoundsNavigationViewController;
+(id)instantiateSupportTopicsViewController;
+(id)instantiateTimeZoneNavViewController;
+(id)instantiateTimeZoneViewController;
+(id)instantiateTimelineContainerController;
+(id)instantiateTimelineFeedbackViewController;
+(id)instantiateTrendsViewController;
+(id)instantiateTutorialViewController;

@end
