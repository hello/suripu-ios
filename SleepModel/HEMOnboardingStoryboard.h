//
// HEMOnboardingStoryboard.h
// Copyright (c) 2015 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)networkReuseIdentifier;
+(NSString *)pillSetupTextCellReuseIdentifier;
+(NSString *)pillSetupImageCellReuseIdentifier;

/** Segue Identifiers */
+(NSString *)alarmToAnotherPillSegueIdentifier;
+(NSString *)audioToSetupSegueIdentifier;
+(NSString *)beforeSleeptoRoomCheckSegueIdentifier;
+(NSString *)doneSegueIdentifier;
+(NSString *)genderSegueIdentifier;
+(NSString *)getAppSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationSegueIdentifier;
+(NSString *)locationToPushSegueIdentifier;
+(NSString *)moreInfoSegueIdentifier;
+(NSString *)noBleToBirthdaySegueIdentifier;
+(NSString *)pillSetupToColorsSegueIdentifier;
+(NSString *)pushToAudioSegueIdentifier;
+(NSString *)roomcheckToSmartAlarmSegueIdentifier;
+(NSString *)sensePairToPillSegueIdentifier;
+(NSString *)signupToNoBleSegueIdentifier;
+(NSString *)skipPillPairSegue;
+(NSString *)weightSegueIdentifier;
+(NSString *)wifiSegueIdentifier;
+(NSString *)wifiPasswordSegueIdentifier;
+(NSString *)wifiToPillSegueIdentifier;

/** View Controllers */
+(id)instantiateDobViewController;
+(id)instantiateGenderPickerViewController;
+(id)instantiateHeightPickerViewController;
+(id)instantiatePillDescriptionViewController;
+(id)instantiatePillPairViewController;
+(id)instantiateRoomCheckViewController;
+(id)instantiateSenseAudioViewController;
+(id)instantiateSensePairViewController;
+(id)instantiateSenseSetupViewController;
+(id)instantiateSignUpViewController;
+(id)instantiateWeightPickerViewController;
+(id)instantiateWelcomeViewController;
+(id)instantiateWifiPickerViewController;
+(id)instantiateWifiViewController;

@end
