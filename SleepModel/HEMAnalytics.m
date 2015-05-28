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
NSString* const kHEMAnalyticsEventPropSenseId = @"Sense Id";
NSString* const kHEMAnalyticsEventPropPillId = @"Pill Id";
NSString* const kHEMAnalyticsEventPropHealthKit = @"HealthKit";

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
NSString* const kHEManaltyicsEventStatusNotSupported = @"not supported";

// onboarding
//
// Some events fire outside of onboarding b/c the controllers are reused.
// If the event is fired during onboarding, make sure HEMAnalyticsEventOnboardingPrefix
// is added to the event name.
NSString* const HEMAnalyticsEventOnboardingPrefix = @"Onboarding";
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

NSString* const HEMAnalyticsEventOnbStart = @"Onboarding Start";
NSString* const HEMAnalyticsEventAccount = @"Account";
NSString* const HEMAnalyticsEventHealth = @"Health";
NSString* const HEMAnalyticsEventLocation = @"Location";
NSString* const HEMAnalyticsEventNotification = @"Notifications";
NSString* const HEMAnalyticsEventNoBle = @"No BLE";
NSString* const HEMAnalyticsEventAudio = @"Sense Audio";
NSString* const HEMAnalyticsEventSleepPill = @"Sleep Pill";
NSString* const HEMAnalyticsEventPillPlacement = @"Onboarding Pill Placement";
NSString* const HEMAnalyticsEventAnotherPill = @"Onboarding Another Pill";
NSString* const HEMAnalyticsEventPairingMode = @"Pairing Mode Help";
NSString* const HEMAnalyticsEventGetApp = @"Get App";
NSString* const HEMAnalyticsEventSenseColors = @"Onboarding Sense Colors";
NSString* const HEMAnalyticsEventFirstAlarm = @"Onboarding First Alarm";
NSString* const HEMAnalyticsEventRoomCheck = @"Onboarding Room Check";
NSString* const HEMAnalyticsEventOnbEnd = @"Onboarding End";
NSString* const HEMAnalyticsEventSkip = @"Skip";
NSString* const HEMAnalyticsEventBirthday = @"Birthday";
NSString* const HEMAnalyticsEventGender = @"Gender";
NSString* const HEMAnalyticsEventHeight = @"Height";
NSString* const HEMAnalyticsEventWeight = @"Weight";
NSString* const HEMAnalyticsEventSenseSetup = @"Sense Setup";
NSString* const HEMAnalyticsEventPairSense = @"Pair Sense";
NSString* const HEMAnalyticsEventWiFi = @"WiFi";
NSString* const HEMAnalyticsEventWiFiScan = @"WiFi Scan"; // fires when app auto starts a scan
NSString* const HEMAnalyticsEventWiFiRescan = @"WiFi Rescan"; // fires when user triggers a scan
NSString* const HEMAnalyticsEventWiFiPass = @"WiFi Password";
NSString* const HEMAnalyticsEventWiFiSubmit = @"WiFi Credentials Submitted";
NSString* const kHEMAnalyticsEventPropSecurityType = @"Security Type";
NSString* const kHEMAnalyticsEventPropWiFiOther = @"Is Other";
NSString* const kHEMAnalyticsEventPropWiFiRSSI = @"RSSI";
NSString* const HEMAnalyticsEventPairPill = @"Pair Pill";
NSString* const HEMAnalyticsEventPairPillRetry = @"Pair Pill Retry";
NSString* const kHEMAnalyticsEventPropOnBScreen = @"Screen";
NSString* const kHEMAnalyticsEventPropScreenPillPairing = @"pill_pairing";

// main app
NSString* const kHEMAnalyticsEventAppLaunched = @"App Launched";
NSString* const kHEMAnalyticsEventAppClosed = @"App Closed";
NSString* const kHEMAnalyticsEventPropEvent = @"event";
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

// time zone
NSString* const HEMAnalyticsEventTimeZone = @"Time Zone";
NSString* const HEMAnalyticsEventTimeZoneChanged = @"Time Zone Changed";
NSString* const HEMAnalyticsEventPropTZ = @"tz";

// device management
NSString* const kHEMAnalyticsEventDeviceAction = @"Device Action";
NSString* const kHEMAnalyticsEventDeviceActionFactoryRestore = @"factory restore";
NSString* const kHEMAnalyticsEventDeviceActionPairingMode = @"enable pairing mode";
NSString* const kHEMAnalyticsEventDeviceActionUnpairSense = @"unpair Sense";
NSString* const kHEMAnalyticsEventDeviceActionUnpairPill = @"unpair Sleep Pill";

// timeline
NSString* const HEMAnalyticsEventTimelineBarLongPress = @"Long press sleep duration bar";
NSString* const kHEMAnalyticsEventTimeline = @"Timeline";
NSString* const kHEMAnalyticsEventTimelineChanged = @"Timeline swipe"; // case sensitive, to be same as android
NSString* const kHEMAnalyticsEventTimelineAction = @"Timeline Event tapped";
NSString* const kHEMAnalyticsEventTimelineOpen = @"Timeline opened";
NSString* const kHEMAnalyticsEventTimelineClose = @"Timeline closed";
NSString* const HEMAnalyticsEventSleepScoreBreakdown = @"Sleep Score breakdown";
NSString* const HEMAnalyticsEventTimelineZoomOut = @"Timeline zoomed out";
NSString* const HEMAnalyticsEventTimelineZoomIn = @"Timeline zoomed in";
NSString* const HEMAnalyticsEventTimelineAdjustTime = @"Timeline adjust time tapped";
NSString* const HEMAnalyticsEventTimelineDataRequest = @"Timeline data request";
NSString* const HEMAnalyticsEventTimelineAlarmShortcut = @"Timeline alarm shorcut";

// alarms
NSString* const kHEMAnalyticsEventAlarms = @"Alarms";
NSString* const HEMAnalyticsEventCreateNewAlarm = @"Create new alarm";
NSString* const HEMAnalyticsEventSwitchSmartAlarm = @"Flip smart alarm switch";
NSString* const HEMAnalyticsEventSwitchSmartAlarmOn = @"on";
NSString* const HEMAnalyticsEventSaveAlarm = @"Save alarm";
NSString* const HEMAnalyticsEventSaveAlarmHour = @"hour";
NSString* const HEMAnalyticsEventSaveAlarmMinute = @"minute";
NSString* const HEMAnalyticsEventSaveAlarmError = @"error";

// system alerts
NSString* const HEMAnalyticsEventSystemAlert = @"System Alert";
NSString* const HEMAnalyticsEventSystemAlertAction = @"System Alert Action";
NSString* const HEMAnalyticsEventSysAlertActionLater = @"later";
NSString* const HEMAnalyticsEventSysAlertActionNow = @"now";

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
