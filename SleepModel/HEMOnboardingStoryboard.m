//
// HEMOnboardingStoryboard.m
// File generated using Ovaltine

#import <UIKit/UIKit.h>
#import "HEMOnboardingStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMonboarding = @"Onboarding";
static NSString *const _HEMageViewController = @"ageViewController";
static NSString *const _HEMbluetoothViewController = @"bluetoothViewController";
static NSString *const _HEMdataIntro = @"dataIntro";
static NSString *const _HEMdataIntroViewController = @"dataIntroViewController";
static NSString *const _HEMpill = @"pill";
static NSString *const _HEMsetup = @"setup";
static NSString *const _HEMsignUpViewController = @"signUpViewController";
static NSString *const _HEMsignup = @"signup";
static NSString *const _HEMskip = @"skip";
static NSString *const _HEMsleepQuestionIntro = @"sleepQuestionIntro";
static NSString *const _HEMsleepQuestionIntroViewController = @"sleepQuestionIntroViewController";
static NSString *const _HEMwelcome = @"welcome";
static NSString *const _HEMwifi = @"wifi";
static NSString *const _HEMwifiViewController = @"wifiViewController";

@implementation HEMOnboardingStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMonboarding bundle:[NSBundle mainBundle]]); }



/** Segue Identifiers */
+(NSString *)signupSegueIdentifier { return _HEMsignup; }
+(NSString *)setupSegueIdentifier { return _HEMsetup; }
+(NSString *)pillSegueIdentifier { return _HEMpill; }
+(NSString *)dataIntroSegueIdentifier { return _HEMdataIntro; }
+(NSString *)sleepQuestionIntroSegueIdentifier { return _HEMsleepQuestionIntro; }
+(NSString *)skipSegueIdentifier { return _HEMskip; }
+(NSString *)wifiSegueIdentifier { return _HEMwifi; }

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwelcome]; }
+(UIViewController *)instantiateSignUpViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsignUpViewController]; }
+(UIViewController *)instantiateDataIntroViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdataIntroViewController]; }
+(UIViewController *)instantiateAgeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMageViewController]; }
+(UIViewController *)instantiateWifiViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiViewController]; }
+(UIViewController *)instantiateSleepQuestionIntroViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepQuestionIntroViewController]; }
+(UIViewController *)instantiateBluetoothViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMbluetoothViewController]; }

@end
