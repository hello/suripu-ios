//
// HEMOnboardingStoryboard.h
// File generated using Ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;



/** Segue Identifiers */
+(NSString *)signupSegueIdentifier;
+(NSString *)setupSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)dataIntroSegueIdentifier;
+(NSString *)sleepQuestionIntroSegueIdentifier;
+(NSString *)skipSegueIdentifier;
+(NSString *)wifiSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController;
+(UIViewController *)instantiateSignUpViewController;
+(UIViewController *)instantiateDataIntroViewController;
+(UIViewController *)instantiateAgeViewController;
+(UIViewController *)instantiateWifiViewController;
+(UIViewController *)instantiateSleepQuestionIntroViewController;
+(UIViewController *)instantiateBluetoothViewController;

@end
