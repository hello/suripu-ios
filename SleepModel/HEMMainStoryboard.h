//
// HEMMainStoryboard.h
// Copyright (c) 2014 Hello Inc. All rights reserved.
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
+(NSString *)unitCellReuseIdentifier;
+(NSString *)settingsCellReuseIdentifier;
+(NSString *)deviceCellReuseIdentifier;
+(NSString *)senseInfoCellReuseIdentifier;
+(NSString *)firmwareUpdateCellReuseIdentifier;
+(NSString *)pillInfoCellReuseIdentifier;
+(NSString *)alarmListCellReuseIdentifier;
+(NSString *)alarmChoiceCellReuseIdentifier;
+(NSString *)sensorGraphCellReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)questionReuseIdentifier;
+(NSString *)insightReuseIdentifier;

/** Segue Identifiers */
+(NSString *)accountSettingsSegueIdentifier;
+(NSString *)alarmRepeatSegueIdentifier;
+(NSString *)devicesSettingsSegueIdentifier;
+(NSString *)infoSettingsSegueIdentifier;
+(NSString *)noSleepPillSegueIdentifier;
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
+(id)instantiateNoSleepPillController;
+(id)instantiatePersonalInfoViewController;
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
