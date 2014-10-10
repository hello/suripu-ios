//
// HEMOnboardingStoryboard.m
// File generated using Ovaltine

#import <UIKit/UIKit.h>
#import "HEMOnboardingStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMonboarding = @"Onboarding";
static NSString *const _HEMbluetoothViewController = @"bluetoothViewController";
static NSString *const _HEMdobViewController = @"dobViewController";
static NSString *const _HEMgender = @"gender";
static NSString *const _HEMheight = @"height";
static NSString *const _HEMlocation = @"location";
static NSString *const _HEMmoreInfo = @"moreInfo";
static NSString *const _HEMpill = @"pill";
static NSString *const _HEMsenseSetup = @"senseSetup";
static NSString *const _HEMsignUpViewController = @"signUpViewController";
static NSString *const _HEMweight = @"weight";
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
+(NSString *)heightSegueIdentifier { return _HEMheight; }
+(NSString *)locationSegueIdentifier { return _HEMlocation; }
+(NSString *)senseSetupSegueIdentifier { return _HEMsenseSetup; }
+(NSString *)wifiSegueIdentifier { return _HEMwifi; }

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwelcome]; }
+(UIViewController *)instantiateSignUpViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsignUpViewController]; }
+(UIViewController *)instantiateDobViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdobViewController]; }
+(UIViewController *)instantiateHeightViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMheight]; }
+(UIViewController *)instantiateWifiViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiViewController]; }
+(UIViewController *)instantiateGenderViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMgender]; }
+(UIViewController *)instantiateWeightViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMweight]; }
+(UIViewController *)instantiateBluetoothViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMbluetoothViewController]; }

@end
