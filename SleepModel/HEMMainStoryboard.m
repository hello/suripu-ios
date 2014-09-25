//
// HEMMainStoryboard.m
// File generated using Ovaltine

#import <UIKit/UIKit.h>
#import "HEMMainStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMmain = @"Main";
static NSString *const _HEMalarmSoundTableViewController = @"alarmSoundTableViewController";
static NSString *const _HEMalarmViewController = @"alarmViewController";
static NSString *const _HEMcurrentConditionsCell = @"currentConditionsCell";
static NSString *const _HEMcurrentController = @"currentController";
static NSString *const _HEMcurrentNavController = @"currentNavController";
static NSString *const _HEMinfo = @"info";
static NSString *const _HEMdeviceCell = @"deviceCell";
static NSString *const _HEMpillInfoCell = @"pillInfoCell";
static NSString *const _HEMsenseInfoCell = @"senseInfoCell";
static NSString *const _HEMfirmwareUpdateCell = @"firmwareUpdateCell";
static NSString *const _HEMpill = @"pill";
static NSString *const _HEMsense = @"sense";
static NSString *const _HEMinsightCell = @"insightCell";
static NSString *const _HEMsettingsCell = @"settingsCell";
static NSString *const _HEMpersonal = @"personal";
static NSString *const _HEMinfoSettings = @"infoSettings";
static NSString *const _HEMunitsSettings = @"unitsSettings";
static NSString *const _HEMdevicesSettings = @"devicesSettings";
static NSString *const _HEMpersonalInfo = @"personalInfo";
static NSString *const _HEMpickSoundSegue = @"pickSoundSegue";
static NSString *const _HEMsensorViewController = @"sensorViewController";
static NSString *const _HEMsettingsController = @"settingsController";
static NSString *const _HEMsettingsNavController = @"settingsNavController";
static NSString *const _HEMsleepGraphController = @"sleepGraphController";
static NSString *const _HEMsleepGraphNavController = @"sleepGraphNavController";
static NSString *const _HEMsleepHistoryController = @"sleepHistoryController";
static NSString *const _HEMsleepQuestions = @"sleepQuestions";
static NSString *const _HEMsleepSoundCell = @"sleepSoundCell";
static NSString *const _HEMsleepSoundViewController = @"sleepSoundViewController";
static NSString *const _HEMtimeSliceCell = @"timeSliceCell";

@implementation HEMMainStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMmain bundle:[NSBundle mainBundle]]); }

/** Cell Reuse Identifiers */
+(NSString *)sleepSoundCellReuseIdentifier { return _HEMsleepSoundCell; }
+(NSString *)infoReuseIdentifier { return _HEMinfo; }
+(NSString *)currentConditionsCellReuseIdentifier { return _HEMcurrentConditionsCell; }
+(NSString *)timeSliceCellReuseIdentifier { return _HEMtimeSliceCell; }
+(NSString *)insightCellReuseIdentifier { return _HEMinsightCell; }
+(NSString *)deviceCellReuseIdentifier { return _HEMdeviceCell; }
+(NSString *)pillInfoCellReuseIdentifier { return _HEMpillInfoCell; }
+(NSString *)senseInfoCellReuseIdentifier { return _HEMsenseInfoCell; }
+(NSString *)firmwareUpdateCellReuseIdentifier { return _HEMfirmwareUpdateCell; }
+(NSString *)settingsCellReuseIdentifier { return _HEMsettingsCell; }

/** Segue Identifiers */
+(NSString *)pickSoundSegueSegueIdentifier { return _HEMpickSoundSegue; }
+(NSString *)pillSegueIdentifier { return _HEMpill; }
+(NSString *)senseSegueIdentifier { return _HEMsense; }
+(NSString *)infoSettingsSegueIdentifier { return _HEMinfoSettings; }
+(NSString *)unitsSettingsSegueIdentifier { return _HEMunitsSettings; }
+(NSString *)devicesSegueIdentifier { return _HEMdevicesSettings; }

/** View Controllers */
+(UIViewController *)instantiateAlarmViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmViewController]; }
+(UIViewController *)instantiateSettingsController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsController]; }
+(UIViewController *)instantiateSleepQuestionsViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepQuestions]; }
+(UIViewController *)instantiateSensorViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsensorViewController]; }
+(UIViewController *)instantiateSleepSoundViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepSoundViewController]; }
+(UIViewController *)instantiatePersonalInfoViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpersonalInfo]; }
+(UIViewController *)instantiateCurrentController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMcurrentController]; }
+(UIViewController *)instantiateAlarmSoundTableViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmSoundTableViewController]; }
+(UIViewController *)instantiateSleepGraphController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepGraphController]; }
+(UIViewController *)instantiateSleepHistoryController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepHistoryController]; }
+(UIViewController *)instantiateCurrentNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMcurrentNavController]; }
+(UIViewController *)instantiateSettingsNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsNavController]; }
+(UIViewController *)instantiateSleepGraphNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepGraphNavController]; }

@end
