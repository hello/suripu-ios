//
//  HEMAnalytics.m
//  Sense
//
//  Created by Jimmy Lu on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAccount.h>
#import <SenseKit/SENServiceAccount.h>
#import <SenseKit/SENAnalytics.h>

#import "HEMAnalytics.h"

// general
NSString* const kHEMAnalyticsEventError = @"Error";
NSString* const kHEMAnalyticsEventWarning = @"Warning";
NSString* const kHEMAnalyticsEventHelp = @"Help";
NSString* const kHEMAnalyticsEventVideo = @"Play Video";
NSString* const kHEMAnalyticsEventPropMessage = @"Message";
NSString* const kHEMAnalyticsEventPropAction = @"Action";
NSString* const kHEMAnalyticsEventPropDate = @"Date";
NSString* const kHEMAnalyticsEventPropType = @"Type";
NSString* const kHEMAnalyticsEventPropPlatform = @"Platform";
NSString* const kHEMAnalyticsEventPlatform = @"iOS";
NSString* const kHEMAnalyticsEventPropName = @"Name";
NSString* const kHEMAnalyticsEventPropGender = @"Gender";
NSString* const kHEMAnalyticsEventPropAccount = @"Account Id";

// special mixpanel special properties
NSString* const kHEMAnalyticsEventMpPropName = @"$name";
NSString* const kHEMAnalyticsEventMpPropCreated = @"$created";

// permissions
NSString* const kHEMAnalyticsEventPermissionLoc = @"Permission Location";
NSString* const kHEManaltyicsEventPropStatus = @"Status";
NSString* const kHEManaltyicsEventStatusSkipped = @"skipped";
NSString* const kHEManaltyicsEventStatusEnabled = @"enabled";
NSString* const kHEManaltyicsEventStatusDisabled = @"disabled";
NSString* const kHEManaltyicsEventStatusDenied = @"denied";

// onboarding
NSString* const kHEMAnalyticsEventOnBNoSense = @"I don't have a Sense";
NSString* const kHEMAnalyticsEventOnBHelp = @"Onboarding Help";
NSString* const kHEMAnalyticsEventPropStep = @"onboarding_step";
NSString* const kHEMAnalyticsEventPropBluetooth = @"bluetooth";
NSString* const kHEMAnalyticsEventPropAudio = @"enhanced_audio";
NSString* const kHEMAnalyticsEventPropSensePairingMode = @"sense_pairing_mode";
NSString* const kHEMAnalyticsEventPropSensePairing = @"sense_pairing";
NSString* const kHEMAnalyticsEventPropSenseSetup = @"setup_sense";
NSString* const kHEMAnalyticsEventPropWiFiScan = @"wifi_scan";
NSString* const kHEMAnalyticsEventPropWiFiPass = @"sign_into_wifi";
NSString* const kHEMAnalyticsEventPropPillPairing = @"pill_pairing";
NSString* const kHEMAnalyticsEventPropPillPlacement = @"pill_placement";
NSString* const kHEMAnalyticsEventPropPillAnother = @"pill_another";
NSString* const kHEMAnalyticsEventOnBStart = @"Onboarding Start";
NSString* const kHEMAnalyticsEventOnBAccount = @"Onboarding Account";
NSString* const kHEMAnalyticsEventOnBBirthday = @"Onboarding Birthday";
NSString* const kHEMAnalyticsEventOnBGender = @"Onboarding Gender";
NSString* const kHEMAnalyticsEventOnBHeight = @"Onboarding Height";
NSString* const kHEMAnalyticsEventOnBWeight = @"Onboarding Weight";
NSString* const kHEMAnalyticsEventOnBLocation = @"Onboarding Location";
NSString* const kHEMAnalyticsEventOnBNotification = @"Onboarding Notifications";
NSString* const kHEMAnalyticsEventOnBNoBle = @"Onboarding No BLE";
NSString* const kHEMAnalyticsEventOnBAudio = @"Onboarding Sense Audio";
NSString* const kHEMAnalyticsEventOnBSenseSetup = @"Onboarding Sense Setup";
NSString* const kHEMAnalyticsEventOnBPairSense = @"Onboarding Pair Sense";
NSString* const kHEMAnalyticsEventOnBWiFi = @"Onboarding WiFi";
NSString* const kHEMAnalyticsEventOnBWiFiScan = @"Onboarding WiFi Scan";
NSString* const kHEMAnalyticsEventOnBWiFiPass = @"Onboarding WiFi Password";
NSString* const kHEMAnalyticsEventOnBSleepPill = @"Onboarding Sleep Pill";
NSString* const kHEMAnalyticsEventOnBPairPill = @"Onboarding Pair Pill";
NSString* const kHEMAnalyticsEventOnBPillPlacement = @"Onboarding Pill Placement";
NSString* const kHEMAnalyticsEventOnBAnotherPill = @"Onboarding Another Pill";
NSString* const kHEMAnalyticsEventOnBPairingMode = @"Onboarding Pairing Mode Help";
NSString* const kHEMAnalyticsEventOnBGetApp = @"Onboarding Get App";
NSString* const kHEMAnalyticsEventOnBSenseColors = @"Onboarding Sense Colors";
NSString* const kHEMAnalyticsEventOnBFirstAlarm = @"Onboarding First Alarm";
NSString* const kHEMAnalyticsEventOnBRoomCheck = @"Onboarding Room Check";
NSString* const kHEMAnalyticsEventOnBEnd = @"Onboarding End";
NSString* const kHEMAnalyticsEventOnBSkip = @"Onboarding Skip";
NSString* const kHEMAnalyticsEventPropOnBScreen = @"Screen";
NSString* const kHEMAnalyticsEventPropScreenPillPairing = @"pill_pairing";

// main app
NSString* const kHEMAnalyticsEventAppLaunched = @"App Launched";
NSString* const kHEMAnalyticsEventAppClosed = @"App Closed";
NSString* const kHEMAnalyticsEventAlarms = @"Alarms";
NSString* const kHEMAnalyticsEventTimeline = @"Timeline";
NSString* const kHEMAnalyticsEventTimelineAction = @"Timeline Action";
NSString* const kHEMAnalyticsEventPropEvent = @"event";
NSString* const kHEMAnalyticsEventDrawer = @"Drawer Action";
NSString* const kHEMAnalyticsEventPropOpen = @"open";
NSString* const kHEMAnalyticsEventPropClose = @"close";
NSString* const kHEMAnalyticsEventEmailSupport = @"Contact Support";
NSString* const kHEMAnalyticsEventSettings = @"Settings";
NSString* const kHEMAnalyticsEventTrends = @"Trends";
NSString* const kHEMAnalyticsEventCurrentConditions = @"Current Conditions";
NSString* const kHEMAnalyticsEventFeed = @"Insights";
NSString* const kHEMAnalyticsEventQuestion = @"Question";
NSString* const kHEMAnalyticsEventAccount = @"Account";
NSString* const kHEMAnalyticsEventInsight = @"Insight Detail";
NSString* const kHEMAnalyticsEventDevices = @"Devices";
NSString* const kHEMAnalyticsEventUnitsNTime = @"Units/Time";
NSString* const kHEMAnalyticsEventSensor = @"Sensor History";
NSString* const kHEMAnalyticsEventPropSensorName = @"sensor_name";
NSString* const kHEMAnalyticsEventSense = @"Sense Detail";
NSString* const kHEMAnalyticsEventPill = @"Pill Detail";

// authentication
NSString* const kHEMAnalyticsEventSignInStart = @"Sign In Start";
NSString* const kHEMAnalyticsEventSignIn = @"Signed In";
NSString* const kHEMAnalyticsEventSignOut = @"Signed Out";

// device management
NSString* const kHEMAnalyticsEventDeviceAction = @"Device Action";
NSString* const kHEMAnalyticsEventDeviceActionFactoryRestore = @"factory restore";
NSString* const kHEMAnalyticsEventDeviceActionPairingMode = @"enable pairing mode";
NSString* const kHEMAnalyticsEventDeviceActionUnpairSense = @"unpair Sense";
NSString* const kHEMAnalyticsEventDeviceActionUnpairPill = @"unpair Sleep Pill";

// timeline
NSString* const HEMAnalyticsEventTimelineBarLongPress = @"Long press sleep duration bar";

@implementation HEMAnalytics

+ (void)trackSignUpWithName:(NSString*)userName {
    NSString* name = userName ?: @"";
    NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
    if ([accountId length] == 0) {
        // checking this case as it seemed to have happened before
        DDLogInfo(@"account id not found after sign up!");
        accountId = @"";
    }
    
    [SENAnalytics userWithId:[SENAuthorizationService accountIdOfAuthorizedUser]
     didSignUpWithProperties:@{kHEMAnalyticsEventMpPropName : name,
                               kHEMAnalyticsEventMpPropCreated : [NSDate date],
                               kHEMAnalyticsEventPropAccount : accountId,
                               kHEMAnalyticsEventPropPlatform : kHEMAnalyticsEventPlatform}];
    
    // these are properties that will be sent up for every event
    [SENAnalytics setGlobalEventProperties:@{kHEMAnalyticsEventPropName : name,
                                             kHEMAnalyticsEventPropPlatform : kHEMAnalyticsEventPlatform}];
}

+ (void)trackUserSession {
    SENAccount* account = [[SENServiceAccount sharedService] account];
    NSMutableDictionary* uProperties = [NSMutableDictionary dictionary]; // updates profile properties
    NSMutableDictionary* gProperties = [NSMutableDictionary dictionary]; // props sent for every event
    NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
    
    if (account != nil) {
        NSString* name = [account name] ?: @"";
        uProperties[kHEMAnalyticsEventMpPropName] = name;
        
        if (accountId) {
            uProperties[kHEMAnalyticsEventPropAccount] = accountId;
        }
        
        gProperties[kHEMAnalyticsEventPropName] = name;
    }
    
    uProperties[kHEMAnalyticsEventPropPlatform] = kHEMAnalyticsEventPlatform;
    gProperties[kHEMAnalyticsEventPropPlatform] = kHEMAnalyticsEventPlatform;
    // need to additionally set the account id as a separate property so that it
    // is shown in as a user property when viewing People in Mixpanel.  If not using
    // mixpanel, we can probably just remove it
    
    if (accountId) {
        [SENAnalytics setUserId:accountId properties:uProperties];
    }
    [SENAnalytics setGlobalEventProperties:gProperties];
    
}

+ (void)updateGender:(SENAccountGender)gender {
    NSString* genderString = nil;
    switch (gender) {
        case SENAccountGenderFemale:
            genderString = @"female";
            break;
        case SENAccountGenderMale:
            genderString = @"male";
            break;
        default:
            genderString = @"other";
            break;
    }
    [SENAnalytics setUserProperties:@{kHEMAnalyticsEventPropGender : genderString}];
}

@end
