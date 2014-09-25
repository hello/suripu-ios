//
// HEMMainStoryboard.h
// File generated using Ovaltine

#import <Foundation/Foundation.h>

@interface HEMMainStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)sleepSoundCellReuseIdentifier;
+(NSString *)infoReuseIdentifier;
+(NSString *)currentConditionsCellReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)insightCellReuseIdentifier;
+(NSString *)deviceCellReuseIdentifier;
+(NSString *)pillInfoCellReuseIdentifier;
+(NSString *)senseInfoCellReuseIdentifier;
+(NSString *)firmwareUpdateCellReuseIdentifier;
+(NSString *)settingsCellReuseIdentifier;

/** Segue Identifiers */
+(NSString *)pickSoundSegueSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)senseSegueIdentifier;
+(NSString *)infoSettingsSegueIdentifier;
+(NSString *)unitsSettingsSegueIdentifier;
+(NSString *)devicesSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateAlarmViewController;
+(UIViewController *)instantiateSettingsController;
+(UIViewController *)instantiateSleepQuestionsViewController;
+(UIViewController *)instantiateSensorViewController;
+(UIViewController *)instantiateSleepSoundViewController;
+(UIViewController *)instantiatePersonalInfoViewController;
+(UIViewController *)instantiateCurrentController;
+(UIViewController *)instantiateAlarmSoundTableViewController;
+(UIViewController *)instantiateSleepGraphController;
+(UIViewController *)instantiateSleepHistoryController;
+(UIViewController *)instantiateCurrentNavController;
+(UIViewController *)instantiateSettingsNavController;
+(UIViewController *)instantiateSleepGraphNavController;

@end
