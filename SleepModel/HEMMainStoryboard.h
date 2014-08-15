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
+(UIViewController *)instantiateSensorViewController;
+(UIViewController *)instantiateSleepSoundViewController;
+(UIViewController *)instantiateCurrentController;
+(UIViewController *)instantiateAlarmSoundTableViewController;
+(UIViewController *)instantiateLastNightController;
+(UIViewController *)instantiateSleepHistoryController;
+(UIViewController *)instantiateCurrentNavController;
+(UIViewController *)instantiateSettingsNavController;
+(UIViewController *)instantiateLastNightNavController;

@end
