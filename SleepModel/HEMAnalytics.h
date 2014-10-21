//
//  HEMAnalytics.h
//  Sense
//
//  Created by Jimmy Lu on 10/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAnalytics.h>

// general
extern NSString* const kHEMAnalyticsEventError;
extern NSString* const kHEMAnalyticsEventHelp;
extern NSString* const kHEMAnalyticsEventVideo;
extern NSString* const kHEMAnalyticsEventPropMessage;

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
extern NSString* const kHEMAnalyticsEventOnBSetupStart;
extern NSString* const kHEMAnalyticsEventOnBTwoPill;
extern NSString* const kHEMAnalyticsEventOnBAddPill;
extern NSString* const kHEMAnalyticsEventOnBNoBle;
extern NSString* const kHEMAnalyticsEventOnBSenseSetup;
extern NSString* const kHEMAnalyticsEventOnBPairSense;
extern NSString* const kHEMAnalyticsEventOnBSetupWiFi;
extern NSString* const kHEMAnalyticsEventOnBSetupPill;
extern NSString* const kHEMAnalyticsEventOnBPairPill;
extern NSString* const kHEMAnalyticsEventOnBEnd;
extern NSString* const kHEMAnalyticsEventAlarm;
extern NSString* const kHEMAnalyticsEventTimeline;

// authentication
extern NSString* const kHEMAnalyticsEventSignInStart;
extern NSString* const kHEMAnalyticsEventSignIn;
extern NSString* const kHEMAnalyticsEventSignOut;
