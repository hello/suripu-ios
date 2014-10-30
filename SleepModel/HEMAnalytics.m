//
//  HEMAnalytics.m
//  Sense
//
//  Created by Jimmy Lu on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMAnalytics.h"

// general
NSString* const kHEMAnalyticsEventError = @"Error";
NSString* const kHEMAnalyticsEventHelp = @"Help";
NSString* const kHEMAnalyticsEventVideo = @"Play Video";
NSString* const kHEMAnalyticsEventPropMessage = @"message";
NSString* const kHEMAnalyticsEventPropAction = @"action";
NSString* const kHEMAnalyticsEventPropDuration = @"duration";

// permissions
NSString* const kHEMAnalyticsEventPermissionLoc = @"Permission Location";
NSString* const kHEManaltyicsEventPropStatus = @"status";
NSString* const kHEManaltyicsEventStatusSkipped = @"skipped";
NSString* const kHEManaltyicsEventStatusEnabled = @"enabled";
NSString* const kHEManaltyicsEventStatusDisabled = @"disabled";
NSString* const kHEManaltyicsEventStatusDenied = @"denied";

// onboarding
NSString* const kHEMAnalyticsEventOnBStart = @"Onboarding Start";
NSString* const kHEMAnalyticsEventOnBBirthday = @"Onboarding Birthday";
NSString* const kHEMAnalyticsEventOnBGender = @"Onboarding Gender";
NSString* const kHEMAnalyticsEventOnBHeight = @"Onboarding Height";
NSString* const kHEMAnalyticsEventOnBWeight = @"Onboarding Weight";
NSString* const kHEMAnalyticsEventOnBLocation = @"Onboarding Location";
NSString* const kHEMAnalyticsEventOnBSetupStart = @"Onboarding Setup Start";
NSString* const kHEMAnalyticsEventOnBTwoPill = @"Onboarding Setup Two Pill";
NSString* const kHEMAnalyticsEventOnBAddPill = @"Onboarding Add Pill";
NSString* const kHEMAnalyticsEventOnBNoBle = @"Onboarding No BLE";
NSString* const kHEMAnalyticsEventOnBSenseSetup = @"Onboarding Sense Setup";
NSString* const kHEMAnalyticsEventOnBPairSense = @"Onboarding Pair Sense";
NSString* const kHEMAnalyticsEventOnBSetupWiFi = @"Onboarding Setup WiFi";
NSString* const kHEMAnalyticsEventOnBWiFiScan = @"Onboarding WiFi Scan";
NSString* const kHEMAnalyticsEventOnBWiFiScanComplete = @"Onboarding WiFi Scan Complete";
NSString* const kHEMAnalyticsEventOnBWiFiPass = @"Onboarding WiFi Password";
NSString* const kHEMAnalyticsEventOnBSetupPill = @"Onboarding Setup Pill";
NSString* const kHEMAnalyticsEventOnBPairPill = @"Onboarding Pair Pill";
NSString* const kHEMAnalyticsEventOnBEnd = @"Onboarding End";
NSString* const kHEMAnalyticsEventAlarm = @"Alarm";
NSString* const kHEMAnalyticsEventTimeline = @"Timeline";

// authentication
NSString* const kHEMAnalyticsEventSignInStart = @"Sign In Start";
NSString* const kHEMAnalyticsEventSignIn = @"Signed In";
NSString* const kHEMAnalyticsEventSignOut = @"Signed Out";

// device management
NSString* const kHEMAnalyticsEventDeviceAction = @"Device Action";
NSString* const kHEMAnalyticsEventDeviceFactoryRestore = @"factory restore";
NSString* const kHEMAnalyticsEventDevicePairingMode = @"enable pairing mode";
