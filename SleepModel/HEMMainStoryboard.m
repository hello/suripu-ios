//
// HEMMainStoryboard.m
// File generated using Ovaltine

#import <UIKit/UIKit.h>
#import "HEMMainStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMmain = @"Main";
static NSString *const _HEMalarmChoiceCell = @"alarmChoiceCell";
static NSString *const _HEMalarmListCellIdentifier = @"alarmListCellIdentifier";
static NSString *const _HEMalarmListViewController = @"alarmListViewController";
static NSString *const _HEMalarmRepeat = @"alarmRepeat";
static NSString *const _HEMalarmRepeatTableViewController = @"alarmRepeatTableViewController";
static NSString *const _HEMalarmSoundTableViewController = @"alarmSoundTableViewController";
static NSString *const _HEMalarmViewController = @"alarmViewController";
static NSString *const _HEMcurrentConditionsCell = @"currentConditionsCell";
static NSString *const _HEMcurrentController = @"currentController";
static NSString *const _HEMcurrentNavController = @"currentNavController";
static NSString *const _HEMdeviceCell = @"deviceCell";
static NSString *const _HEMdevicesSettings = @"devicesSettings";
static NSString *const _HEMfirmwareUpdateCell = @"firmwareUpdateCell";
static NSString *const _HEMinfo = @"info";
static NSString *const _HEMinfoSettings = @"infoSettings";
static NSString *const _HEMinsightCell = @"insightCell";
static NSString *const _HEMnoSleepPill = @"noSleepPill";
static NSString *const _HEMpersonalInfo = @"personalInfo";
static NSString *const _HEMpickSoundSegue = @"pickSoundSegue";
static NSString *const _HEMpill = @"pill";
static NSString *const _HEMpillInfoCell = @"pillInfoCell";
static NSString *const _HEMsense = @"sense";
static NSString *const _HEMsenseInfoCell = @"senseInfoCell";
static NSString *const _HEMsensorViewController = @"sensorViewController";
static NSString *const _HEMsettingsCell = @"settingsCell";
static NSString *const _HEMsettingsController = @"settingsController";
static NSString *const _HEMsettingsNavController = @"settingsNavController";
static NSString *const _HEMsleepGraphController = @"sleepGraphController";
static NSString *const _HEMsleepGraphNavController = @"sleepGraphNavController";
static NSString *const _HEMsleepHistoryController = @"sleepHistoryController";
static NSString *const _HEMsleepQuestions = @"sleepQuestions";
static NSString *const _HEMtimeSliceCell = @"timeSliceCell";
static NSString *const _HEMunitCell = @"unitCell";
static NSString *const _HEMunitsSettings = @"unitsSettings";

@implementation HEMMainStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMmain bundle:[NSBundle mainBundle]]); }

/** Cell Reuse Identifiers */
+(NSString *)unitCellReuseIdentifier { return _HEMunitCell; }
+(NSString *)settingsCellReuseIdentifier { return _HEMsettingsCell; }
+(NSString *)deviceCellReuseIdentifier { return _HEMdeviceCell; }
+(NSString *)senseInfoCellReuseIdentifier { return _HEMsenseInfoCell; }
+(NSString *)firmwareUpdateCellReuseIdentifier { return _HEMfirmwareUpdateCell; }
+(NSString *)pillInfoCellReuseIdentifier { return _HEMpillInfoCell; }
+(NSString *)infoReuseIdentifier { return _HEMinfo; }
+(NSString *)currentConditionsCellReuseIdentifier { return _HEMcurrentConditionsCell; }
+(NSString *)alarmListCellIdentifier { return _HEMalarmListCellIdentifier; }
+(NSString *)alarmChoiceCellReuseIdentifier { return _HEMalarmChoiceCell; }
+(NSString *)timeSliceCellReuseIdentifier { return _HEMtimeSliceCell; }
+(NSString *)insightCellReuseIdentifier { return _HEMinsightCell; }

/** Segue Identifiers */
+(NSString *)pickSoundSegueSegueIdentifier { return _HEMpickSoundSegue; }
+(NSString *)alarmRepeatSegueIdentifier { return _HEMalarmRepeat; }
+(NSString *)infoSettingsSegueIdentifier { return _HEMinfoSettings; }
+(NSString *)unitsSettingsSegueIdentifier { return _HEMunitsSettings; }
+(NSString *)devicesSettingsSegueIdentifier { return _HEMdevicesSettings; }
+(NSString *)pillSegueIdentifier { return _HEMpill; }
+(NSString *)senseSegueIdentifier { return _HEMsense; }
+(NSString *)noSleepPillSegueIdentifier { return _HEMnoSleepPill; }

/** View Controllers */
+(UIViewController *)instantiateAlarmViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmViewController]; }
+(UIViewController *)instantiateSleepQuestionsViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepQuestions]; }
+(UIViewController *)instantiateSettingsController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsController]; }
+(UIViewController *)instantiateSensorViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsensorViewController]; }
+(UIViewController *)instantiatePersonalInfoViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpersonalInfo]; }
+(UIViewController *)instantiateCurrentController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMcurrentController]; }
+(UIViewController *)instantiateAlarmListViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmListViewController]; }
+(UIViewController *)instantiateAlarmSoundTableViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmSoundTableViewController]; }
+(UIViewController *)instantiateSleepGraphController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepGraphController]; }
+(UIViewController *)instantiateSleepHistoryController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepHistoryController]; }
+(UIViewController *)instantiateCurrentNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMcurrentNavController]; }
+(UIViewController *)instantiateSettingsNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsNavController]; }
+(UIViewController *)instantiateSleepGraphNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepGraphNavController]; }
+(UIViewController *)instantiateAlarmRepeatTableViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmRepeatTableViewController]; }

@end
