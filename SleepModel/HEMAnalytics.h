//
//  HEMAnalytics.h
//  Sense
//
//  Created by Jimmy Lu on 10/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAnalytics.h>
#import <SenseKit/SENAccount.h>

// general
extern NSString* const kHEMAnalyticsEventError;
extern NSString* const kHEMAnalyticsEventHelp;
extern NSString* const kHEMAnalyticsEventVideo;
extern NSString* const kHEMAnalyticsEventPropMessage;
extern NSString* const kHEMAnalyticsEventPropAction;
extern NSString* const kHEMAnalyticsEventPropPlatform;
extern NSString* const kHEMAnalyticsEventPlatform;
extern NSString* const kHEMAnalyticsEventPropName;
extern NSString* const kHEMAnalyticsEventMpPropName;
extern NSString* const kHEMAnalyticsEventPropGender;
extern NSString* const kHEMAnalyticsEventPropAccount;

// permissions
extern NSString* const kHEMAnalyticsEventPermissionLoc;
extern NSString* const kHEManaltyicsEventPropStatus;
extern NSString* const kHEManaltyicsEventStatusSkipped;
extern NSString* const kHEManaltyicsEventStatusEnabled;
extern NSString* const kHEManaltyicsEventStatusDenied;
extern NSString* const kHEManaltyicsEventStatusDisabled;

// onboarding
extern NSString* const kHEMAnalyticsEventOnBStart;
extern NSString* const kHEMAnalyticsEventOnBBirthday;
extern NSString* const kHEMAnalyticsEventOnBGender;
extern NSString* const kHEMAnalyticsEventOnBHeight;
extern NSString* const kHEMAnalyticsEventOnBWeight;
extern NSString* const kHEMAnalyticsEventOnBLocation;
extern NSString* const kHEMAnalyticsEventOnBNotification;
extern NSString* const kHEMAnalyticsEventOnBSetupStart;
extern NSString* const kHEMAnalyticsEventOnBSecondPillCheck;
extern NSString* const kHEMAnalyticsEventOnBNoBle;
extern NSString* const kHEMAnalyticsEventOnBSenseSetup;
extern NSString* const kHEMAnalyticsEventOnBPairSense;
extern NSString* const kHEMAnalyticsEventOnBWiFi;
extern NSString* const kHEMAnalyticsEventOnBWiFiScan;
extern NSString* const kHEMAnalyticsEventOnBWiFiPass;
extern NSString* const kHEMAnalyticsEventOnBPairPill;
extern NSString* const kHEMAnalyticsEventOnBPillPlacement;
extern NSString* const kHEMAnalyticsEventOnBAnotherPill;
extern NSString* const kHEMAnalyticsEventOnBPairingOff;
extern NSString* const kHEMAnalyticsEventOnBGetApp;
extern NSString* const kHEMAnalyticsEventOnBSenseColors;
extern NSString* const kHEMAnalyticsEventOnBFirstAlarm;
extern NSString* const kHEMAnalyticsEventOnBRoomCheck;
extern NSString* const kHEMAnalyticsEventOnBEnd;

// main
extern NSString* const kHEMAnalyticsEventAlarm;
extern NSString* const kHEMAnalyticsEventTimeline;

// authentication
extern NSString* const kHEMAnalyticsEventSignInStart;
extern NSString* const kHEMAnalyticsEventSignIn;
extern NSString* const kHEMAnalyticsEventSignOut;

// device management
extern NSString* const kHEMAnalyticsEventDeviceAction;
extern NSString* const kHEMAnalyticsEventDeviceFactoryRestore;
extern NSString* const kHEMAnalyticsEventDevicePairingMode;

@interface HEMAnalytics : NSObject

+ (void)trackSignUpWithName:(NSString*)userName;
+ (void)trackUserSession;
+ (void)updateGender:(SENAccountGender)gender;

@end