//
// HEMOnboardingStoryboard.m
// Copyright (c) 2014 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <UIKit/UIKit.h>
#import "HEMOnboardingStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMonboarding = @"Onboarding";
static NSString *const _HEMbluetoothViewController = @"bluetoothViewController";
static NSString *const _HEMdobViewController = @"dobViewController";
static NSString *const _HEMdone = @"done";
static NSString *const _HEMfirstPillSenseSetup = @"firstPillSenseSetup";
static NSString *const _HEMgender = @"gender";
static NSString *const _HEMgenderPicker = @"genderPicker";
static NSString *const _HEMgetSetup = @"getSetup";
static NSString *const _HEMheight = @"height";
static NSString *const _HEMheightPicker = @"heightPicker";
static NSString *const _HEMlocation = @"location";
static NSString *const _HEMmoreInfo = @"moreInfo";
static NSString *const _HEMneedBluetooth = @"needBluetooth";
static NSString *const _HEMnetwork = @"network";
static NSString *const _HEMnoBleToSetup = @"noBleToSetup";
static NSString *const _HEMpill = @"pill";
static NSString *const _HEMpillIntro = @"pillIntro";
static NSString *const _HEMpillNeedBluetooth = @"pillNeedBluetooth";
static NSString *const _HEMsecondPillNeedBle = @"secondPillNeedBle";
static NSString *const _HEMsecondPillToSense = @"secondPillToSense";
static NSString *const _HEMsenseSetup = @"senseSetup";
static NSString *const _HEMsenseToPill = @"senseToPill";
static NSString *const _HEMsignUpViewController = @"signUpViewController";
static NSString *const _HEMweight = @"weight";
static NSString *const _HEMweightPicker = @"weightPicker";
static NSString *const _HEMwelcome = @"welcome";
static NSString *const _HEMwifi = @"wifi";
static NSString *const _HEMwifiPassword = @"wifiPassword";
static NSString *const _HEMwifiViewController = @"wifiViewController";

@implementation HEMOnboardingStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMonboarding bundle:[NSBundle mainBundle]]); }

/** Cell Reuse Identifiers */
+(NSString *)networkReuseIdentifier { return _HEMnetwork; }

/** Segue Identifiers */
+(NSString *)doneSegueIdentifier { return _HEMdone; }
+(NSString *)firstPillSenseSetupSegueIdentifier { return _HEMfirstPillSenseSetup; }
+(NSString *)genderSegueIdentifier { return _HEMgender; }
+(NSString *)heightSegueIdentifier { return _HEMheight; }
+(NSString *)locationSegueIdentifier { return _HEMlocation; }
+(NSString *)moreInfoSegueIdentifier { return _HEMmoreInfo; }
+(NSString *)needBluetoothSegueIdentifier { return _HEMneedBluetooth; }
+(NSString *)noBleToSetupSegueIdentifier { return _HEMnoBleToSetup; }
+(NSString *)pillSegueIdentifier { return _HEMpill; }
+(NSString *)pillNeedBluetoothSegueIdentifier { return _HEMpillNeedBluetooth; }
+(NSString *)secondPillNeedBleSegueIdentifier { return _HEMsecondPillNeedBle; }
+(NSString *)secondPillToSenseSegueIdentifier { return _HEMsecondPillToSense; }
+(NSString *)senseSetupSegueIdentifier { return _HEMsenseSetup; }
+(NSString *)senseToPillSegueIdentifier { return _HEMsenseToPill; }
+(NSString *)weightSegueIdentifier { return _HEMweight; }
+(NSString *)wifiSegueIdentifier { return _HEMwifi; }
+(NSString *)wifiPasswordSegueIdentifier { return _HEMwifiPassword; }

/** View Controllers */
+(UIViewController *)instantiateBluetoothViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMbluetoothViewController]; }
+(UIViewController *)instantiateDobViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdobViewController]; }
+(UIViewController *)instantiateGenderPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMgenderPicker]; }
+(UIViewController *)instantiateGetSetupViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMgetSetup]; }
+(UIViewController *)instantiateHeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMheightPicker]; }
+(UIViewController *)instantiatePillIntroViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillIntro]; }
+(UIViewController *)instantiateSignUpViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsignUpViewController]; }
+(UIViewController *)instantiateWeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMweightPicker]; }
+(UIViewController *)instantiateWelcomeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwelcome]; }
+(UIViewController *)instantiateWifiViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiViewController]; }

@end
