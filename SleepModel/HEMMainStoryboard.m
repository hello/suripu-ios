//
// HEMMainStoryboard.m
// Copyright (c) 2015 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <UIKit/UIKit.h>
#import "HEMMainStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMmain = @"Main";
static NSString *const _HEMaccountSettings = @"accountSettings";
static NSString *const _HEMactions = @"actions";
static NSString *const _HEMalarmChoiceCell = @"alarmChoiceCell";
static NSString *const _HEMalarmDeleteCell = @"alarmDeleteCell";
static NSString *const _HEMalarmListCell = @"alarmListCell";
static NSString *const _HEMalarmListEmptyCell = @"alarmListEmptyCell";
static NSString *const _HEMalarmListNavViewController = @"alarmListNavViewController";
static NSString *const _HEMalarmListStatusCell = @"alarmListStatusCell";
static NSString *const _HEMalarmListViewController = @"alarmListViewController";
static NSString *const _HEMalarmNavController = @"alarmNavController";
static NSString *const _HEMalarmRepeat = @"alarmRepeat";
static NSString *const _HEMalarmRepeatCell = @"alarmRepeatCell";
static NSString *const _HEMalarmRepeatTableViewController = @"alarmRepeatTableViewController";
static NSString *const _HEMalarmSoundCell = @"alarmSoundCell";
static NSString *const _HEMalarmSwitchCell = @"alarmSwitchCell";
static NSString *const _HEMalarmViewController = @"alarmViewController";
static NSString *const _HEMchoice = @"choice";
static NSString *const _HEMchoiceCell = @"choiceCell";
static NSString *const _HEMcurrentNavController = @"currentNavController";
static NSString *const _HEMdevice = @"device";
static NSString *const _HEMdevicesSettings = @"devicesSettings";
static NSString *const _HEMexplanation = @"explanation";
static NSString *const _HEMimage = @"image";
static NSString *const _HEMinfo = @"info";
static NSString *const _HEMinsight = @"insight";
static NSString *const _HEMinsightFeed = @"insightFeed";
static NSString *const _HEMmultiple = @"multiple";
static NSString *const _HEMnotificationSettings = @"notificationSettings";
static NSString *const _HEMoverTime = @"overTime";
static NSString *const _HEMpair = @"pair";
static NSString *const _HEMpickSound = @"pickSound";
static NSString *const _HEMpill = @"pill";
static NSString *const _HEMpreference = @"preference";
static NSString *const _HEMquestion = @"question";
static NSString *const _HEMsense = @"sense";
static NSString *const _HEMsensorGraphCell = @"sensorGraphCell";
static NSString *const _HEMsensorViewController = @"sensorViewController";
static NSString *const _HEMsettingsCell = @"settingsCell";
static NSString *const _HEMsettingsController = @"settingsController";
static NSString *const _HEMsettingsNavController = @"settingsNavController";
static NSString *const _HEMsignout = @"signout";
static NSString *const _HEMsingle = @"single";
static NSString *const _HEMsleepGraphController = @"sleepGraphController";
static NSString *const _HEMsleepGraphNavController = @"sleepGraphNavController";
static NSString *const _HEMsleepHistoryController = @"sleepHistoryController";
static NSString *const _HEMsleepInsight = @"sleepInsight";
static NSString *const _HEMsleepQuestions = @"sleepQuestions";
static NSString *const _HEMtext = @"text";
static NSString *const _HEMtimeSliceCell = @"timeSliceCell";
static NSString *const _HEMtimelineFeedback = @"timelineFeedback";
static NSString *const _HEMtrendGraph = @"trendGraph";
static NSString *const _HEMtrends = @"trends";
static NSString *const _HEMunitCell = @"unitCell";
static NSString *const _HEMunitsSettings = @"unitsSettings";
static NSString *const _HEMupdateEmail = @"updateEmail";
static NSString *const _HEMupdatePassword = @"updatePassword";
static NSString *const _HEMwarning = @"warning";

@implementation HEMMainStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMmain bundle:[NSBundle mainBundle]]); }

/** Cell Reuse Identifiers */
+(NSString *)actionsReuseIdentifier { return _HEMactions; }
+(NSString *)alarmChoiceCellReuseIdentifier { return _HEMalarmChoiceCell; }
+(NSString *)alarmDeleteCellReuseIdentifier { return _HEMalarmDeleteCell; }
+(NSString *)alarmListCellReuseIdentifier { return _HEMalarmListCell; }
+(NSString *)alarmListEmptyCellReuseIdentifier { return _HEMalarmListEmptyCell; }
+(NSString *)alarmListStatusCellReuseIdentifier { return _HEMalarmListStatusCell; }
+(NSString *)alarmRepeatCellReuseIdentifier { return _HEMalarmRepeatCell; }
+(NSString *)alarmSoundCellReuseIdentifier { return _HEMalarmSoundCell; }
+(NSString *)alarmSwitchCellReuseIdentifier { return _HEMalarmSwitchCell; }
+(NSString *)choiceCellReuseIdentifier { return _HEMchoiceCell; }
+(NSString *)deviceReuseIdentifier { return _HEMdevice; }
+(NSString *)explanationReuseIdentifier { return _HEMexplanation; }
+(NSString *)imageReuseIdentifier { return _HEMimage; }
+(NSString *)infoReuseIdentifier { return _HEMinfo; }
+(NSString *)insightReuseIdentifier { return _HEMinsight; }
+(NSString *)multipleReuseIdentifier { return _HEMmultiple; }
+(NSString *)overTimeReuseIdentifier { return _HEMoverTime; }
+(NSString *)pairReuseIdentifier { return _HEMpair; }
+(NSString *)preferenceReuseIdentifier { return _HEMpreference; }
+(NSString *)questionReuseIdentifier { return _HEMquestion; }
+(NSString *)sensorGraphCellReuseIdentifier { return _HEMsensorGraphCell; }
+(NSString *)settingsCellReuseIdentifier { return _HEMsettingsCell; }
+(NSString *)signoutReuseIdentifier { return _HEMsignout; }
+(NSString *)singleReuseIdentifier { return _HEMsingle; }
+(NSString *)textReuseIdentifier { return _HEMtext; }
+(NSString *)timeSliceCellReuseIdentifier { return _HEMtimeSliceCell; }
+(NSString *)trendGraphReuseIdentifier { return _HEMtrendGraph; }
+(NSString *)unitCellReuseIdentifier { return _HEMunitCell; }
+(NSString *)warningReuseIdentifier { return _HEMwarning; }

/** Segue Identifiers */
+(NSString *)accountSettingsSegueIdentifier { return _HEMaccountSettings; }
+(NSString *)alarmRepeatSegueIdentifier { return _HEMalarmRepeat; }
+(NSString *)choiceSegueIdentifier { return _HEMchoice; }
+(NSString *)devicesSettingsSegueIdentifier { return _HEMdevicesSettings; }
+(NSString *)notificationSettingsSegueIdentifier { return _HEMnotificationSettings; }
+(NSString *)pickSoundSegueIdentifier { return _HEMpickSound; }
+(NSString *)pillSegueIdentifier { return _HEMpill; }
+(NSString *)senseSegueIdentifier { return _HEMsense; }
+(NSString *)unitsSettingsSegueIdentifier { return _HEMunitsSettings; }
+(NSString *)updateEmailSegueIdentifier { return _HEMupdateEmail; }
+(NSString *)updatePasswordSegueIdentifier { return _HEMupdatePassword; }

/** View Controllers */
+(id)instantiateAlarmListNavViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmListNavViewController]; }
+(id)instantiateAlarmListViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmListViewController]; }
+(id)instantiateAlarmNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmNavController]; }
+(id)instantiateAlarmRepeatTableViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmRepeatTableViewController]; }
+(id)instantiateAlarmViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmViewController]; }
+(id)instantiateCurrentNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMcurrentNavController]; }
+(id)instantiateInsightFeedViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMinsightFeed]; }
+(id)instantiateSensorViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsensorViewController]; }
+(id)instantiateSettingsController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsController]; }
+(id)instantiateSettingsNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsNavController]; }
+(id)instantiateSleepGraphController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepGraphController]; }
+(id)instantiateSleepGraphNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepGraphNavController]; }
+(id)instantiateSleepHistoryController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepHistoryController]; }
+(id)instantiateSleepInsightViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepInsight]; }
+(id)instantiateSleepQuestionsViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepQuestions]; }
+(id)instantiateTimelineFeedbackViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMtimelineFeedback]; }
+(id)instantiateTrendsViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMtrends]; }

@end
