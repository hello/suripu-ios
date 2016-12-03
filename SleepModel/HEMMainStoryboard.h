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
+(NSString *)alarmExpansionCellReuseIdentifier;
+(NSString *)alarmDeleteCellReuseIdentifier;
+(NSString *)toggleReuseIdentifier;
+(NSString *)configurationReuseIdentifier;
+(NSString *)singleReuseIdentifier;
+(NSString *)multipleReuseIdentifier;
+(NSString *)imageReuseIdentifier;
+(NSString *)summaryReuseIdentifier;
+(NSString *)titleReuseIdentifier;
+(NSString *)loadingReuseIdentifier;
+(NSString *)detailReuseIdentifier;
+(NSString *)aboutReuseIdentifier;
+(NSString *)optionReuseIdentifier;
+(NSString *)infoCellReuseIdentifier;
+(NSString *)configReuseIdentifier;
+(NSString *)currentValueReuseIdentifier;
+(NSString *)chartReuseIdentifier;
+(NSString *)scaleReuseIdentifier;
+(NSString *)alarmListCellReuseIdentifier;
+(NSString *)alarmListEmptyCellReuseIdentifier;
+(NSString *)alarmListStatusCellReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)sensorReuseIdentifier;
+(NSString *)groupReuseIdentifier;
+(NSString *)errorReuseIdentifier;
+(NSString *)pairReuseIdentifier;
+(NSString *)questionReuseIdentifier;
+(NSString *)insightReuseIdentifier;
+(NSString *)welcomeReuseIdentifier;
+(NSString *)commandsReuseIdentifier;
+(NSString *)commandGroupReuseIdentifier;
+(NSString *)examplesReuseIdentifier;
+(NSString *)settingsReuseIdentifier;
+(NSString *)messageReuseIdentifier;
+(NSString *)calendarReuseIdentifier;
+(NSString *)barReuseIdentifier;
+(NSString *)bubblesReuseIdentifier;
+(NSString *)listItemReuseIdentifier;
+(NSString *)summaryViewCellReuseIdentifier;
+(NSString *)breakdownLineCellReuseIdentifier;

/** Segue Identifiers */
+(NSString *)alarmRepeatSegueIdentifier;
+(NSString *)alarmSoundsSegueIdentifier;
+(NSString *)alarmsSegueIdentifier;
+(NSString *)detailSegueIdentifier;
+(NSString *)expansionConfigSegueIdentifier;
+(NSString *)listSegueIdentifier;
+(NSString *)sleepSoundsSegueIdentifier;

/** View Controllers */
+(id)instantiateRootViewController;
+(id)instantiateActionSheetViewController;
+(id)instantiateAlarmListNavViewController;
+(id)instantiateAlarmListViewController;
+(id)instantiateAlarmNavController;
+(id)instantiateAlarmViewController;
+(id)instantiateBreakdownController;
+(id)instantiateCurrentNavController;
+(id)instantiateExpansionConfigViewController;
+(id)instantiateFeedViewController;
+(id)instantiateInfoNavigationController;
+(id)instantiateInfoViewController;
+(id)instantiateInsightsFeedViewController;
+(id)instantiateListItemViewController;
+(id)instantiateSleepGraphController;
+(id)instantiateSleepHistoryController;
+(id)instantiateSleepInsightViewController;
+(id)instantiateSleepQuestionsViewController;
+(id)instantiateSleepSoundViewController;
+(id)instantiateSoundsContainerViewController;
+(id)instantiateSoundsNavigationViewController;
+(id)instantiateTimelineFeedbackViewController;
+(id)instantiateTrendsViewController;
+(id)instantiateTutorialViewController;
+(id)instantiateVoiceViewController;

@end
