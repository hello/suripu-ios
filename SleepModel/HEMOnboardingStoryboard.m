//
// HEMOnboardingStoryboard.m
// Copyright (c) 2014 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <UIKit/UIKit.h>
#import "HEMOnboardingStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMonboarding = @"Onboarding";
static NSString *const _HEManotherPillToBeforeSleep = @"anotherPillToBeforeSleep";
static NSString *const _HEMbeforeSleepToAlarm = @"beforeSleepToAlarm";
static NSString *const _HEMbeforeSleeptoRoomCheck = @"beforeSleeptoRoomCheck";
static NSString *const _HEMbluetoothOn = @"bluetoothOn";
static NSString *const _HEMbluetoothViewController = @"bluetoothViewController";
static NSString *const _HEMdobViewController = @"dobViewController";
static NSString *const _HEMdone = @"done";
static NSString *const _HEMgender = @"gender";
static NSString *const _HEMgenderPicker = @"genderPicker";
static NSString *const _HEMgetApp = @"getApp";
static NSString *const _HEMheight = @"height";
static NSString *const _HEMheightPicker = @"heightPicker";
static NSString *const _HEMlocation = @"location";
static NSString *const _HEMlocationToPush = @"locationToPush";
static NSString *const _HEMmoreInfo = @"moreInfo";
static NSString *const _HEMnetwork = @"network";
static NSString *const _HEMpillPair = @"pillPair";
static NSString *const _HEMpushToNoBle = @"pushToNoBle";
static NSString *const _HEMpushToSenseSetup = @"pushToSenseSetup";
static NSString *const _HEMroomCheck = @"roomCheck";
static NSString *const _HEMsecondPillCheck = @"secondPillCheck";
static NSString *const _HEMsenseSetup = @"senseSetup";
static NSString *const _HEMsenseToPill = @"senseToPill";
static NSString *const _HEMsignUpViewController = @"signUpViewController";
static NSString *const _HEMweight = @"weight";
static NSString *const _HEMweightPicker = @"weightPicker";
static NSString *const _HEMwelcome = @"welcome";
static NSString *const _HEMwifi = @"wifi";
static NSString *const _HEMwifiPassword = @"wifiPassword";
static NSString *const _HEMwifiPicker = @"wifiPicker";
static NSString *const _HEMwifiViewController = @"wifiViewController";

@implementation HEMOnboardingStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMonboarding bundle:[NSBundle mainBundle]]); }

/** Cell Reuse Identifiers */
+(NSString *)networkReuseIdentifier { return _HEMnetwork; }

/** Segue Identifiers */
+(NSString *)anotherPillToBeforeSleepSegueIdentifier { return _HEManotherPillToBeforeSleep; }
+(NSString *)beforeSleepToAlarmSegueIdentifier { return _HEMbeforeSleepToAlarm; }
+(NSString *)beforeSleeptoRoomCheckSegueIdentifier { return _HEMbeforeSleeptoRoomCheck; }
+(NSString *)bluetoothOnSegueIdentifier { return _HEMbluetoothOn; }
+(NSString *)doneSegueIdentifier { return _HEMdone; }
+(NSString *)genderSegueIdentifier { return _HEMgender; }
+(NSString *)getAppSegueIdentifier { return _HEMgetApp; }
+(NSString *)heightSegueIdentifier { return _HEMheight; }
+(NSString *)locationSegueIdentifier { return _HEMlocation; }
+(NSString *)locationToPushSegueIdentifier { return _HEMlocationToPush; }
+(NSString *)moreInfoSegueIdentifier { return _HEMmoreInfo; }
+(NSString *)pushToNoBleSegueIdentifier { return _HEMpushToNoBle; }
+(NSString *)pushToSenseSetupSegueIdentifier { return _HEMpushToSenseSetup; }
+(NSString *)secondPillCheckSegueIdentifier { return _HEMsecondPillCheck; }
+(NSString *)senseToPillSegueIdentifier { return _HEMsenseToPill; }
+(NSString *)weightSegueIdentifier { return _HEMweight; }
+(NSString *)wifiSegueIdentifier { return _HEMwifi; }
+(NSString *)wifiPasswordSegueIdentifier { return _HEMwifiPassword; }

/** View Controllers */
+(UIViewController *)instantiateBluetoothViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMbluetoothViewController]; }
+(UIViewController *)instantiateDobViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdobViewController]; }
+(UIViewController *)instantiateGenderPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMgenderPicker]; }
+(UIViewController *)instantiateHeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMheightPicker]; }
+(UIViewController *)instantiatePillPairViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillPair]; }
+(UIViewController *)instantiateRoomCheckViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMroomCheck]; }
+(UIViewController *)instantiateSenseSetupViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsenseSetup]; }
+(UIViewController *)instantiateSignUpViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsignUpViewController]; }
+(UIViewController *)instantiateWeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMweightPicker]; }
+(UIViewController *)instantiateWelcomeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwelcome]; }
+(UIViewController *)instantiateWifiPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiPicker]; }
+(UIViewController *)instantiateWifiViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiViewController]; }

@end
