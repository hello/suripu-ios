//
// HEMOnboardingStoryboard.h
// Copyright (c) 2016 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)titleReuseIdentifier;
+(NSString *)passwordReuseIdentifier;
+(NSString *)emailReuseIdentifier;
+(NSString *)photoReuseIdentifier;
+(NSString *)firstNameReuseIdentifier;
+(NSString *)lastNameReuseIdentifier;
+(NSString *)networkReuseIdentifier;
+(NSString *)pillSetupTextCellReuseIdentifier;
+(NSString *)pillSetupVideoCellReuseIdentifier;

/** Segue Identifiers */
+(NSString *)audioToSetupSegueIdentifier;
+(NSString *)beforeSleepToSmartAlarmSegueIdentifier;
+(NSString *)beforeSleeptoRoomCheckSegueIdentifier;
+(NSString *)doneSegueIdentifier;
+(NSString *)genderSegueIdentifier;
+(NSString *)healthKitToLocationSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationToPushSegueIdentifier;
+(NSString *)moreInfoSegueIdentifier;
+(NSString *)noBleToBirthdaySegueIdentifier;
+(NSString *)notificationToAudioSegueIdentifier;
+(NSString *)pillSetupToColorsSegueIdentifier;
+(NSString *)roomCheckToSmartAlarmSegueIdentifier;
+(NSString *)sensePairToPillSegueIdentifier;
+(NSString *)signupToNoBleSegueIdentifier;
+(NSString *)skipPillPairSegue;
+(NSString *)weightSegueIdentifier;
+(NSString *)weightToHealthKitSegueIdentifier;
+(NSString *)weightToLocationSegueIdentifier;
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
+(id)instantiateSenseColorsViewController;
+(id)instantiateSensePairViewController;
+(id)instantiateSenseSetupViewController;
+(id)instantiateWeightPickerViewController;
+(id)instantiateWelcomeViewController;
+(id)instantiateWifiPickerViewController;
+(id)instantiateWifiViewController;

@end
