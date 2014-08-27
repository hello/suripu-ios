//
// HEMOnboardingStoryboard.h
// File generated using Ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;



/** Segue Identifiers */
+(NSString *)signupSegueIdentifier;
+(NSString *)setupSegueIdentifier;
+(NSString *)moreSegueIdentifier;
+(NSString *)skipSegueIdentifier;
+(NSString *)wifiSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController;
+(UIViewController *)instantiateSignUpViewController;
+(UIViewController *)instantiateAgeViewController;
+(UIViewController *)instantiateWifiViewController;
+(UIViewController *)instantiateBluetoothViewController;

@end
