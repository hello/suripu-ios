//
// HEMOnboardingStoryboard.h
// File generated using Ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;





/** View Controllers */
+(UIViewController *)instantiateSignUpViewController;
+(UIViewController *)instantiateWifiViewController;
+(UIViewController *)instantiateBluetoothViewController;

@end
