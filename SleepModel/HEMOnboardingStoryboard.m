//
// HEMOnboardingStoryboard.m
// File generated using Ovaltine

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
static NSString *const _HEMheight = @"height";
static NSString *const _HEMheightPicker = @"heightPicker";
static NSString *const _HEMlocation = @"location";
static NSString *const _HEMmoreInfo = @"moreInfo";
static NSString *const _HEMneedBluetooth = @"needBluetooth";
static NSString *const _HEMpill = @"pill";
static NSString *const _HEMpillNeedBluetooth = @"pillNeedBluetooth";
static NSString *const _HEMsecondPillNeedBle = @"secondPillNeedBle";
static NSString *const _HEMsecondPillToSense = @"secondPillToSense";
static NSString *const _HEMsenseSetup = @"senseSetup";
static NSString *const _HEMsignUpViewController = @"signUpViewController";
static NSString *const _HEMweight = @"weight";
static NSString *const _HEMweightPicker = @"weightPicker";
static NSString *const _HEMwelcome = @"welcome";
static NSString *const _HEMwifi = @"wifi";
static NSString *const _HEMwifiViewController = @"wifiViewController";

@implementation HEMOnboardingStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMonboarding bundle:[NSBundle mainBundle]]); }



/** Segue Identifiers */
+(NSString *)moreInfoSegueIdentifier { return _HEMmoreInfo; }
+(NSString *)genderSegueIdentifier { return _HEMgender; }
+(NSString *)weightSegueIdentifier { return _HEMweight; }
+(NSString *)pillSegueIdentifier { return _HEMpill; }
+(NSString *)doneSegueIdentifier { return _HEMdone; }
+(NSString *)heightSegueIdentifier { return _HEMheight; }
+(NSString *)locationSegueIdentifier { return _HEMlocation; }
+(NSString *)senseSetupSegueIdentifier { return _HEMsenseSetup; }
+(NSString *)wifiSegueIdentifier { return _HEMwifi; }
+(NSString *)needBluetoothSegueIdentifier { return _HEMneedBluetooth; }
+(NSString *)pillNeedBluetoothSegueIdentifier { return _HEMpillNeedBluetooth; }
+(NSString *)firstPillSenseSetupSegueIdentifier { return _HEMfirstPillSenseSetup; }
+(NSString *)secondPillNeedBleSegueIdentifier { return _HEMsecondPillNeedBle; }
+(NSString *)secondPillToSenseSegueIdentifier { return _HEMsecondPillToSense; }

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwelcome]; }
+(UIViewController *)instantiateSignUpViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsignUpViewController]; }
+(UIViewController *)instantiateDobViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdobViewController]; }
+(UIViewController *)instantiateHeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMheightPicker]; }
+(UIViewController *)instantiateWifiViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiViewController]; }
+(UIViewController *)instantiateGenderPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMgenderPicker]; }
+(UIViewController *)instantiateWeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMweightPicker]; }
+(UIViewController *)instantiateBluetoothViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMbluetoothViewController]; }

@end
