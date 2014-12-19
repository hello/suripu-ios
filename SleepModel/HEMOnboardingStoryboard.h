//
// HEMOnboardingStoryboard.h
// Copyright (c) 2014 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)networkReuseIdentifier;

/** Segue Identifiers */
+(NSString *)anotherPillToBeforeSleepSegueIdentifier;
+(NSString *)beforeSleeptoRoomCheckSegueIdentifier;
+(NSString *)bluetoothOnSegueIdentifier;
+(NSString *)doneSegueIdentifier;
+(NSString *)genderSegueIdentifier;
+(NSString *)getAppSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationSegueIdentifier;
+(NSString *)locationToPushSegueIdentifier;
+(NSString *)moreInfoSegueIdentifier;
+(NSString *)pushToNoBleSegueIdentifier;
+(NSString *)pushToSenseSetupSegueIdentifier;
+(NSString *)secondPillCheckSegueIdentifier;
+(NSString *)senseToPillSegueIdentifier;
+(NSString *)weightSegueIdentifier;
+(NSString *)wifiSegueIdentifier;
+(NSString *)wifiPasswordSegueIdentifier;

/** View Controllers */
+(id)instantiateBluetoothViewController;
+(id)instantiateDobViewController;
+(id)instantiateGenderPickerViewController;
+(id)instantiateHeightPickerViewController;
+(id)instantiatePillPairViewController;
+(id)instantiateRoomCheckViewController;
+(id)instantiateSenseSetupViewController;
+(id)instantiateSignUpViewController;
+(id)instantiateWeightPickerViewController;
+(id)instantiateWelcomeViewController;
+(id)instantiateWifiPickerViewController;
+(id)instantiateWifiViewController;

@end
