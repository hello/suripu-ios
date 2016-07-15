//
// HEMOnboardingStoryboard.m
// Copyright (c) 2016 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <UIKit/UIKit.h>
#import "HEMOnboardingStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMonboarding = @"Onboarding";
static NSString *const _HEMaudioToSetup = @"audioToSetup";
static NSString *const _HEMbeforeSleepToSmartAlarm = @"beforeSleepToSmartAlarm";
static NSString *const _HEMbeforeSleeptoRoomCheck = @"beforeSleeptoRoomCheck";
static NSString *const _HEMdobViewController = @"dobViewController";
static NSString *const _HEMdone = @"done";
static NSString *const _HEMemail = @"email";
static NSString *const _HEMfirstName = @"firstName";
static NSString *const _HEMgender = @"gender";
static NSString *const _HEMgenderPicker = @"genderPicker";
static NSString *const _HEMhealthKitToLocation = @"healthKitToLocation";
static NSString *const _HEMheight = @"height";
static NSString *const _HEMheightPicker = @"heightPicker";
static NSString *const _HEMlastName = @"lastName";
static NSString *const _HEMlocationToPush = @"locationToPush";
static NSString *const _HEMmoreInfo = @"moreInfo";
static NSString *const _HEMnetwork = @"network";
static NSString *const _HEMnoBle = @"noBle";
static NSString *const _HEMnoBleToBirthday = @"noBleToBirthday";
static NSString *const _HEMnotificationToAudio = @"notificationToAudio";
static NSString *const _HEMpassword = @"password";
static NSString *const _HEMphoto = @"photo";
static NSString *const _HEMpillDescription = @"pillDescription";
static NSString *const _HEMpillPair = @"pillPair";
static NSString *const _HEMpillSetupTextCell = @"pillSetupTextCell";
static NSString *const _HEMpillSetupToColors = @"pillSetupToColors";
static NSString *const _HEMpillSetupVideoCell = @"pillSetupVideoCell";
static NSString *const _HEMroomCheck = @"roomCheck";
static NSString *const _HEMroomCheckToSmartAlarm = @"roomCheckToSmartAlarm";
static NSString *const _HEMsenseAudio = @"senseAudio";
static NSString *const _HEMsenseColors = @"senseColors";
static NSString *const _HEMsensePairToPill = @"sensePairToPill";
static NSString *const _HEMsensePairViewController = @"sensePairViewController";
static NSString *const _HEMsenseSetup = @"senseSetup";
static NSString *const _HEMsignupToNoBle = @"signupToNoBle";
static NSString *const _HEMskipPillPairSegue = @"skipPillPairSegue";
static NSString *const _HEMtitle = @"title";
static NSString *const _HEMweight = @"weight";
static NSString *const _HEMweightPicker = @"weightPicker";
static NSString *const _HEMweightToHealthKit = @"weightToHealthKit";
static NSString *const _HEMweightToLocation = @"weightToLocation";
static NSString *const _HEMwelcome = @"welcome";
static NSString *const _HEMwifi = @"wifi";
static NSString *const _HEMwifiPassword = @"wifiPassword";
static NSString *const _HEMwifiPicker = @"wifiPicker";
static NSString *const _HEMwifiToPill = @"wifiToPill";
static NSString *const _HEMwifiViewController = @"wifiViewController";

@implementation HEMOnboardingStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMonboarding bundle:[NSBundle mainBundle]]); }

/** Cell Reuse Identifiers */
+(NSString *)emailReuseIdentifier { return _HEMemail; }
+(NSString *)firstNameReuseIdentifier { return _HEMfirstName; }
+(NSString *)lastNameReuseIdentifier { return _HEMlastName; }
+(NSString *)networkReuseIdentifier { return _HEMnetwork; }
+(NSString *)passwordReuseIdentifier { return _HEMpassword; }
+(NSString *)photoReuseIdentifier { return _HEMphoto; }
+(NSString *)pillSetupTextCellReuseIdentifier { return _HEMpillSetupTextCell; }
+(NSString *)pillSetupVideoCellReuseIdentifier { return _HEMpillSetupVideoCell; }
+(NSString *)titleReuseIdentifier { return _HEMtitle; }

/** Segue Identifiers */
+(NSString *)audioToSetupSegueIdentifier { return _HEMaudioToSetup; }
+(NSString *)beforeSleepToSmartAlarmSegueIdentifier { return _HEMbeforeSleepToSmartAlarm; }
+(NSString *)beforeSleeptoRoomCheckSegueIdentifier { return _HEMbeforeSleeptoRoomCheck; }
+(NSString *)doneSegueIdentifier { return _HEMdone; }
+(NSString *)genderSegueIdentifier { return _HEMgender; }
+(NSString *)healthKitToLocationSegueIdentifier { return _HEMhealthKitToLocation; }
+(NSString *)heightSegueIdentifier { return _HEMheight; }
+(NSString *)locationToPushSegueIdentifier { return _HEMlocationToPush; }
+(NSString *)moreInfoSegueIdentifier { return _HEMmoreInfo; }
+(NSString *)noBleToBirthdaySegueIdentifier { return _HEMnoBleToBirthday; }
+(NSString *)notificationToAudioSegueIdentifier { return _HEMnotificationToAudio; }
+(NSString *)pillSetupToColorsSegueIdentifier { return _HEMpillSetupToColors; }
+(NSString *)roomCheckToSmartAlarmSegueIdentifier { return _HEMroomCheckToSmartAlarm; }
+(NSString *)sensePairToPillSegueIdentifier { return _HEMsensePairToPill; }
+(NSString *)signupToNoBleSegueIdentifier { return _HEMsignupToNoBle; }
+(NSString *)skipPillPairSegue { return _HEMskipPillPairSegue; }
+(NSString *)weightSegueIdentifier { return _HEMweight; }
+(NSString *)weightToHealthKitSegueIdentifier { return _HEMweightToHealthKit; }
+(NSString *)weightToLocationSegueIdentifier { return _HEMweightToLocation; }
+(NSString *)wifiSegueIdentifier { return _HEMwifi; }
+(NSString *)wifiPasswordSegueIdentifier { return _HEMwifiPassword; }
+(NSString *)wifiToPillSegueIdentifier { return _HEMwifiToPill; }

/** View Controllers */
+(id)instantiateDobViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdobViewController]; }
+(id)instantiateGenderPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMgenderPicker]; }
+(id)instantiateHeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMheightPicker]; }
+(id)instantiateNoBleViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMnoBle]; }
+(id)instantiatePillDescriptionViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillDescription]; }
+(id)instantiatePillPairViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillPair]; }
+(id)instantiateRoomCheckViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMroomCheck]; }
+(id)instantiateSenseAudioViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsenseAudio]; }
+(id)instantiateSenseColorsViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsenseColors]; }
+(id)instantiateSensePairViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsensePairViewController]; }
+(id)instantiateSenseSetupViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsenseSetup]; }
+(id)instantiateWeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMweightPicker]; }
+(id)instantiateWelcomeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwelcome]; }
+(id)instantiateWifiPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiPicker]; }
+(id)instantiateWifiViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiViewController]; }

@end
