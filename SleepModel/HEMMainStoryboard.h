//
// HEMMainStoryboard.h
// File generated using Ovaltine

#import <Foundation/Foundation.h>

@interface HEMMainStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)settingsCellReuseIdentifier;
+(NSString *)deviceCellReuseIdentifier;
+(NSString *)senseInfoCellReuseIdentifier;
+(NSString *)firmwareUpdateCellReuseIdentifier;
+(NSString *)pillInfoCellReuseIdentifier;
+(NSString *)infoReuseIdentifier;
+(NSString *)currentConditionsCellReuseIdentifier;
+(NSString *)alarmListCellIdentifier;
+(NSString *)alarmChoiceCellReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)insightCellReuseIdentifier;

/** Segue Identifiers */
+(NSString *)pickSoundSegueSegueIdentifier;
+(NSString *)alarmRepeatSegueIdentifier;
+(NSString *)infoSettingsSegueIdentifier;
+(NSString *)unitsSettingsSegueIdentifier;
+(NSString *)devicesSettingsSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)senseSegueIdentifier;
+(NSString *)noSleepPillSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateAlarmViewController;
+(UIViewController *)instantiateSleepQuestionsViewController;
+(UIViewController *)instantiateSettingsController;
+(UIViewController *)instantiateSensorViewController;
+(UIViewController *)instantiatePersonalInfoViewController;
+(UIViewController *)instantiateCurrentController;
+(UIViewController *)instantiateAlarmListViewController;
+(UIViewController *)instantiateAlarmSoundTableViewController;
+(UIViewController *)instantiateSleepGraphController;
+(UIViewController *)instantiateSleepHistoryController;
+(UIViewController *)instantiateCurrentNavController;
+(UIViewController *)instantiateSettingsNavController;
+(UIViewController *)instantiateSleepGraphNavController;
+(UIViewController *)instantiateAlarmRepeatTableViewController;

@end
