//
// HEMOnboardingStoryboard.h
// Copyright (c) 2015 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)networkReuseIdentifier;

/** Segue Identifiers */
+(NSString *)anotherPillToBeforeSleepSegueIdentifier;
+(NSString *)beforeSleeptoRoomCheckSegueIdentifier;
+(NSString *)doneSegueIdentifier;
+(NSString *)genderSegueIdentifier;
+(NSString *)getAppSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationSegueIdentifier;
+(NSString *)locationToPushSegueIdentifier;
+(NSString *)moreInfoSegueIdentifier;
+(NSString *)noBleToBirthdaySegueIdentifier;
+(NSString *)pushToSenseSetupSegueIdentifier;
+(NSString *)secondPillCheckSegueIdentifier;
+(NSString *)senseToPillSegueIdentifier;
+(NSString *)signupToNoBleSegueIdentifier;
+(NSString *)weightSegueIdentifier;
+(NSString *)wifiSegueIdentifier;
+(NSString *)wifiPasswordSegueIdentifier;

/** View Controllers */
+(id)instantiateDobViewController;
+(id)instantiateGenderPickerViewController;
+(id)instantiateHeightPickerViewController;
+(id)instantiatePillPairViewController;
+(id)instantiateRoomCheckViewController;
+(id)instantiateSensePairViewController;
+(id)instantiateSenseSetupViewController;
+(id)instantiateSignUpViewController;
+(id)instantiateWeightPickerViewController;
+(id)instantiateWelcomeViewController;
+(id)instantiateWifiPickerViewController;
+(id)instantiateWifiViewController;

@end
