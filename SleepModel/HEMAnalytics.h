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
extern NSString* const kHEMAnalyticsEventWarning;
extern NSString* const kHEMAnalyticsEventHelp;
extern NSString* const kHEMAnalyticsEventVideo;
extern NSString* const kHEMAnalyticsEventPropMessage;
extern NSString* const kHEMAnalyticsEventPropAction;
extern NSString* const kHEMAnalyticsEventPropDate;
extern NSString* const kHEMAnalyticsEventPropType;
extern NSString* const kHEMAnalyticsEventPropPlatform;
extern NSString* const kHEMAnalyticsEventPlatform;
extern NSString* const kHEMAnalyticsEventPropName;
extern NSString* const kHEMAnalyticsEventMpPropName;
extern NSString* const kHEMAnalyticsEventPropGender;
extern NSString* const kHEMAnalyticsEventPropAccount;
extern NSString* const kHEMAnalyticsEventPropSenseId;
extern NSString* const kHEMAnalyticsEventPropSenseIdUnpaired;

// permissions
extern NSString* const kHEMAnalyticsEventPermissionLoc;
extern NSString* const kHEManaltyicsEventPropStatus;
extern NSString* const kHEManaltyicsEventStatusSkipped;
extern NSString* const kHEManaltyicsEventStatusEnabled;
extern NSString* const kHEManaltyicsEventStatusDenied;
extern NSString* const kHEManaltyicsEventStatusDisabled;

// onboarding
extern NSString* const kHEMAnalyticsEventOnBNoSense;
extern NSString* const kHEMAnalyticsEventOnBHelp;
extern NSString* const kHEMAnalyticsEventPropStep;
extern NSString* const kHEMAnalyticsEventPropBluetooth;
extern NSString* const kHEMAnalyticsEventPropAudio;
extern NSString* const kHEMAnalyticsEventPropSensePairingMode;
extern NSString* const kHEMAnalyticsEventPropSensePairing;
extern NSString* const kHEMAnalyticsEventPropSenseSetup;
extern NSString* const kHEMAnalyticsEventPropWiFiScan;
extern NSString* const kHEMAnalyticsEventPropWiFiPass;
extern NSString* const kHEMAnalyticsEventOnBWiFiSubmit;
extern NSString* const kHEMAnalyticsEventPropSecurityType;
extern NSString* const kHEMAnalyticsEventPropWiFiOther;
extern NSString* const kHEMAnalyticsEventPropPillPairing;
extern NSString* const kHEMAnalyticsEventPropPillPlacement;
extern NSString* const kHEMAnalyticsEventPropPillAnother;
extern NSString* const kHEMAnalyticsEventOnBStart;
extern NSString* const kHEMAnalyticsEventOnBAccount;
extern NSString* const kHEMAnalyticsEventOnBBirthday;
extern NSString* const kHEMAnalyticsEventOnBGender;
extern NSString* const kHEMAnalyticsEventOnBHeight;
extern NSString* const kHEMAnalyticsEventOnBWeight;
extern NSString* const kHEMAnalyticsEventOnBLocation;
extern NSString* const kHEMAnalyticsEventOnBNotification;
extern NSString* const kHEMAnalyticsEventOnBNoBle;
extern NSString* const kHEMAnalyticsEventOnBAudio;
extern NSString* const kHEMAnalyticsEventOnBSenseSetup;
extern NSString* const kHEMAnalyticsEventOnBPairSense;
extern NSString* const kHEMAnalyticsEventOnBWiFi;
extern NSString* const kHEMAnalyticsEventOnBWiFiScan;
extern NSString* const kHEMAnalyticsEventOnBWiFiPass;
extern NSString* const kHEMAnalyticsEventOnBSleepPill;
extern NSString* const kHEMAnalyticsEventOnBPairPill;
extern NSString* const kHEMAnalyticsEventOnBPillPlacement;
extern NSString* const kHEMAnalyticsEventOnBAnotherPill;
extern NSString* const kHEMAnalyticsEventOnBPairingMode;
extern NSString* const kHEMAnalyticsEventOnBGetApp;
extern NSString* const kHEMAnalyticsEventOnBSenseColors;
extern NSString* const kHEMAnalyticsEventOnBFirstAlarm;
extern NSString* const kHEMAnalyticsEventOnBRoomCheck;
extern NSString* const kHEMAnalyticsEventOnBEnd;
extern NSString* const kHEMAnalyticsEventOnBSkip;
extern NSString* const kHEMAnalyticsEventPropOnBScreen;
extern NSString* const kHEMAnalyticsEventPropScreenPillPairing;

// main
extern NSString* const kHEMAnalyticsEventAppLaunched;
extern NSString* const kHEMAnalyticsEventAppClosed;
extern NSString* const kHEMAnalyticsEventPropEvent;
extern NSString* const kHEMAnalyticsEventDrawer;
extern NSString* const kHEMAnalyticsEventPropOpen;
extern NSString* const kHEMAnalyticsEventPropClose;
extern NSString* const kHEMAnalyticsEventEmailSupport;
extern NSString* const kHEMAnalyticsEventSettings;
extern NSString* const kHEMAnalyticsEventTrends;
extern NSString* const kHEMAnalyticsEventCurrentConditions;
extern NSString* const kHEMAnalyticsEventFeed;
extern NSString* const kHEMAnalyticsEventQuestion;
extern NSString* const kHEMAnalyticsEventAccount;
extern NSString* const kHEMAnalyticsEventInsight;
extern NSString* const kHEMAnalyticsEventDevices;
extern NSString* const kHEMAnalyticsEventUnitsNTime;
extern NSString* const kHEMAnalyticsEventSensor;
extern NSString* const kHEMAnalyticsEventPropSensorName;
extern NSString* const kHEMAnalyticsEventSense;
extern NSString* const kHEMAnalyticsEventPill;

// authentication
extern NSString* const kHEMAnalyticsEventSignInStart;
extern NSString* const kHEMAnalyticsEventSignIn;
extern NSString* const kHEMAnalyticsEventSignOut;

// device management
extern NSString* const kHEMAnalyticsEventDeviceAction;
extern NSString* const kHEMAnalyticsEventDeviceActionFactoryRestore;
extern NSString* const kHEMAnalyticsEventDeviceActionPairingMode;
extern NSString* const kHEMAnalyticsEventDeviceActionUnpairSense;
extern NSString* const kHEMAnalyticsEventDeviceActionUnpairPill;

// timeline
extern NSString* const HEMAnalyticsEventTimelineBarLongPress;
extern NSString* const kHEMAnalyticsEventTimeline;
extern NSString* const kHEMAnalyticsEventTimelineAction;

// alarms
extern NSString* const kHEMAnalyticsEventAlarms;
extern NSString* const HEMAnalyticsEventCreateNewAlarm;
extern NSString* const HEMAnalyticsEventSwitchSmartAlarm;
extern NSString* const HEMAnalyticsEventSwitchSmartAlarmOn;
extern NSString* const HEMAnalyticsEventSaveAlarm;
extern NSString* const HEMAnalyticsEventSaveAlarmHour;
extern NSString* const HEMAnalyticsEventSaveAlarmMinute;
extern NSString* const HEMAnalyticsEventSaveAlarmError;

@interface HEMAnalytics : NSObject

+ (void)trackSignUpWithName:(NSString*)userName;
+ (void)trackUserSession;
+ (void)updateGender:(SENAccountGender)gender;

@end