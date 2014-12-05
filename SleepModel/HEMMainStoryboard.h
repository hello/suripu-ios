//
// HEMMainStoryboard.h
// Copyright (c) 2014 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMMainStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)singleReuseIdentifier;
+(NSString *)unitCellReuseIdentifier;
+(NSString *)settingsCellReuseIdentifier;
+(NSString *)deviceCellReuseIdentifier;
+(NSString *)senseInfoCellReuseIdentifier;
+(NSString *)firmwareUpdateCellReuseIdentifier;
+(NSString *)pillInfoCellReuseIdentifier;
+(NSString *)infoReuseIdentifier;
+(NSString *)alarmListCellIdentifier;
+(NSString *)alarmChoiceCellReuseIdentifier;
+(NSString *)currentConditionsCellReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)insightCellReuseIdentifier;

/** Segue Identifiers */
+(NSString *)accountSettingsSegueIdentifier;
+(NSString *)alarmRepeatSegueIdentifier;
+(NSString *)devicesSettingsSegueIdentifier;
+(NSString *)infoSettingsSegueIdentifier;
+(NSString *)noSleepPillSegueIdentifier;
+(NSString *)pickSoundSegueSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)senseSegueIdentifier;
+(NSString *)showInsightSegueIdentifier;
+(NSString *)unitsSettingsSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateAlarmListViewController;
+(UIViewController *)instantiateAlarmNavController;
+(UIViewController *)instantiateAlarmRepeatTableViewController;
+(UIViewController *)instantiateAlarmSoundTableViewController;
+(UIViewController *)instantiateAlarmViewController;
+(UIViewController *)instantiateCurrentNavController;
+(UIViewController *)instantiateNoSleepPillController;
+(UIViewController *)instantiatePersonalInfoViewController;
+(UIViewController *)instantiateSensorViewController;
+(UIViewController *)instantiateSettingsController;
+(UIViewController *)instantiateSettingsNavController;
+(UIViewController *)instantiateSleepGraphController;
+(UIViewController *)instantiateSleepGraphNavController;
+(UIViewController *)instantiateSleepHistoryController;
+(UIViewController *)instantiateSleepQuestionsViewController;

@end
