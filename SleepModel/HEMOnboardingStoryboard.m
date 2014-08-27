//
// HEMOnboardingStoryboard.m
// File generated using Ovaltine

#import <UIKit/UIKit.h>
#import "HEMOnboardingStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMonboarding = @"Onboarding";
static NSString *const _HEMageViewController = @"ageViewController";
static NSString *const _HEMbluetoothViewController = @"bluetoothViewController";
static NSString *const _HEMmore = @"more";
static NSString *const _HEMsetup = @"setup";
static NSString *const _HEMsignUpViewController = @"signUpViewController";
static NSString *const _HEMsignup = @"signup";
static NSString *const _HEMskip = @"skip";
static NSString *const _HEMwelcome = @"welcome";
static NSString *const _HEMwifi = @"wifi";
static NSString *const _HEMwifiViewController = @"wifiViewController";

@implementation HEMOnboardingStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMonboarding bundle:[NSBundle mainBundle]]); }



/** Segue Identifiers */
+(NSString *)signupSegueIdentifier { return _HEMsignup; }
+(NSString *)setupSegueIdentifier { return _HEMsetup; }
+(NSString *)moreSegueIdentifier { return _HEMmore; }
+(NSString *)skipSegueIdentifier { return _HEMskip; }
+(NSString *)wifiSegueIdentifier { return _HEMwifi; }

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwelcome]; }
+(UIViewController *)instantiateSignUpViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsignUpViewController]; }
+(UIViewController *)instantiateAgeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMageViewController]; }
+(UIViewController *)instantiateWifiViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiViewController]; }
+(UIViewController *)instantiateBluetoothViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMbluetoothViewController]; }

@end
