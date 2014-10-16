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
+(NSString *)doneSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationSegueIdentifier;
+(NSString *)senseSetupSegueIdentifier;
+(NSString *)wifiSegueIdentifier;
+(NSString *)needBluetoothSegueIdentifier;
+(NSString *)pillNeedBluetoothSegueIdentifier;
+(NSString *)firstPillSenseSetupSegueIdentifier;
+(NSString *)secondPillNeedBleSegueIdentifier;
+(NSString *)secondPillToSenseSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController;
+(UIViewController *)instantiateSignUpViewController;
+(UIViewController *)instantiateDobViewController;
+(UIViewController *)instantiateHeightPickerViewController;
+(UIViewController *)instantiateWifiViewController;
+(UIViewController *)instantiateGenderPickerViewController;
+(UIViewController *)instantiateWeightPickerViewController;
+(UIViewController *)instantiateBluetoothViewController;

@end
