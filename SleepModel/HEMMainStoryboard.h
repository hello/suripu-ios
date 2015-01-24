//
// HEMMainStoryboard.h
// Copyright (c) 2015 Hello Inc. All rights reserved.
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
+(NSString *)infoReuseIdentifier;
+(NSString *)preferenceReuseIdentifier;
+(NSString *)unitCellReuseIdentifier;
+(NSString *)settingsCellReuseIdentifier;
+(NSString *)pairReuseIdentifier;
+(NSString *)deviceReuseIdentifier;
+(NSString *)warningReuseIdentifier;
+(NSString *)actionsReuseIdentifier;
+(NSString *)choiceCellReuseIdentifier;
+(NSString *)alarmListCellReuseIdentifier;
+(NSString *)alarmListEmptyCellReuseIdentifier;
+(NSString *)alarmChoiceCellReuseIdentifier;
+(NSString *)sensorGraphCellReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)overTimeReuseIdentifier;
+(NSString *)trendGraphReuseIdentifier;
+(NSString *)questionReuseIdentifier;
+(NSString *)insightReuseIdentifier;

/** Segue Identifiers */
+(NSString *)accountSettingsSegueIdentifier;
+(NSString *)alarmRepeatSegueIdentifier;
+(NSString *)choiceSegueIdentifier;
+(NSString *)devicesSettingsSegueIdentifier;
+(NSString *)pickSoundSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)senseSegueIdentifier;
+(NSString *)unitsSettingsSegueIdentifier;
+(NSString *)updateEmailSegueIdentifier;
+(NSString *)updatePasswordSegueIdentifier;

/** View Controllers */
+(id)instantiateAlarmListNavViewController;
+(id)instantiateAlarmListViewController;
+(id)instantiateAlarmNavController;
+(id)instantiateAlarmRepeatTableViewController;
+(id)instantiateAlarmSoundTableViewController;
+(id)instantiateAlarmViewController;
+(id)instantiateCurrentNavController;
+(id)instantiateInsightFeedViewController;
+(id)instantiateSensorViewController;
+(id)instantiateSettingsController;
+(id)instantiateSettingsNavController;
+(id)instantiateSleepGraphController;
+(id)instantiateSleepGraphNavController;
+(id)instantiateSleepHistoryController;
+(id)instantiateSleepInsightViewController;
+(id)instantiateSleepQuestionsViewController;
+(id)instantiateTrendsViewController;

@end
