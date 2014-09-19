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

/** Segue Identifiers */
+(NSString *)pickSoundSegueSegueIdentifier;
+(NSString *)personalSegueIdentifier;

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
