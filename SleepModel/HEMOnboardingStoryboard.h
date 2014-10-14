//
// HEMOnboardingStoryboard.h
// File generated using Ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;



/** Segue Identifiers */
+(NSString *)moreInfoSegueIdentifier;
+(NSString *)genderSegueIdentifier;
+(NSString *)weightSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationSegueIdentifier;
+(NSString *)senseSetupSegueIdentifier;
+(NSString *)wifiSegueIdentifier;
+(NSString *)needBluetoothSegueIdentifier;
+(NSString *)setupOnePillSegueIdentifier;
+(NSString *)pillNeedBluetoothSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController;
+(UIViewController *)instantiateSignUpViewController;
+(UIViewController *)instantiateDobViewController;
+(UIViewController *)instantiateHeightViewController;
+(UIViewController *)instantiateWifiViewController;
+(UIViewController *)instantiateGenderViewController;
+(UIViewController *)instantiateWeightViewController;
+(UIViewController *)instantiateBluetoothViewController;

@end
