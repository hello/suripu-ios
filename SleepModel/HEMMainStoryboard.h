//
// HEMMainStoryboard.h
// File generated using Ovaltine

#import <Foundation/Foundation.h>

@interface HEMMainStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)sleepSoundCellReuseIdentifier;
+(NSString *)currentConditionsCellReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)insightCellReuseIdentifier;

/** Segue Identifiers */
+(NSString *)pickSoundSegueSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateAlarmViewController;
+(UIViewController *)instantiateSettingsController;
+(UIViewController *)instantiateSleepQuestionsViewController;
+(UIViewController *)instantiateSensorViewController;
+(UIViewController *)instantiateSleepSoundViewController;
+(UIViewController *)instantiateCurrentController;
+(UIViewController *)instantiateAlarmSoundTableViewController;
+(UIViewController *)instantiateSleepGraphController;
+(UIViewController *)instantiateSleepHistoryController;
+(UIViewController *)instantiateCurrentNavController;
+(UIViewController *)instantiateSettingsNavController;
+(UIViewController *)instantiateSleepGraphNavController;

@end
