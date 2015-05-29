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
extern NSString* const kHEMAnalyticsEventPropPillId;
extern NSString* const kHEMAnalyticsEventPropHealthKit;

// permissions
extern NSString* const kHEMAnalyticsEventPermissionLoc;
extern NSString* const kHEManaltyicsEventPropStatus;
extern NSString* const kHEManaltyicsEventStatusSkipped;
extern NSString* const kHEManaltyicsEventStatusEnabled;
extern NSString* const kHEManaltyicsEventStatusDenied;
extern NSString* const kHEManaltyicsEventStatusDisabled;
extern NSString* const kHEManaltyicsEventStatusNotSupported;

// onboarding
extern NSString* const HEMAnalyticsEventOnboardingPrefix;
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
extern NSString* const kHEMAnalyticsEventPropSecurityType;
extern NSString* const kHEMAnalyticsEventPropWiFiOther;
extern NSString* const kHEMAnalyticsEventPropWiFiRSSI;
extern NSString* const kHEMAnalyticsEventPropPillPairing;
extern NSString* const kHEMAnalyticsEventPropPillPlacement;
extern NSString* const kHEMAnalyticsEventPropPillAnother;
extern NSString* const HEMAnalyticsEventOnbStart;
extern NSString* const HEMAnalyticsEventHealth;
extern NSString* const HEMAnalyticsEventAccount;
extern NSString* const HEMAnalyticsEventLocation;
extern NSString* const HEMAnalyticsEventNotification;
extern NSString* const HEMAnalyticsEventNoBle;
extern NSString* const HEMAnalyticsEventAudio;
extern NSString* const HEMAnalyticsEventSleepPill;
extern NSString* const HEMAnalyticsEventPillPlacement;
extern NSString* const HEMAnalyticsEventAnotherPill;
extern NSString* const HEMAnalyticsEventPairingMode;
extern NSString* const HEMAnalyticsEventGetApp;
extern NSString* const HEMAnalyticsEventSenseColors;
extern NSString* const HEMAnalyticsEventFirstAlarm;
extern NSString* const HEMAnalyticsEventRoomCheck;
extern NSString* const HEMAnalyticsEventOnbEnd;
extern NSString* const HEMAnalyticsEventSkip;
extern NSString* const kHEMAnalyticsEventPropOnBScreen;
extern NSString* const kHEMAnalyticsEventPropScreenPillPairing;
extern NSString* const HEMAnalyticsEventBirthday;
extern NSString* const HEMAnalyticsEventGender;
extern NSString* const HEMAnalyticsEventHeight;
extern NSString* const HEMAnalyticsEventWeight;
extern NSString* const HEMAnalyticsEventSenseSetup;
extern NSString* const HEMAnalyticsEventPairSense;
extern NSString* const HEMAnalyticsEventWiFi;
extern NSString* const HEMAnalyticsEventWiFiScan;
extern NSString* const HEMAnalyticsEventWiFiRescan;
extern NSString* const HEMAnalyticsEventWiFiPass;
extern NSString* const HEMAnalyticsEventWiFiSubmit;
extern NSString* const HEMAnalyticsEventPairPill;
extern NSString* const HEMAnalyticsEventPairPillRetry;


// main
extern NSString* const kHEMAnalyticsEventAppLaunched;
extern NSString* const kHEMAnalyticsEventAppClosed;
extern NSString* const kHEMAnalyticsEventPropEvent;
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

// time zone
extern NSString* const HEMAnalyticsEventTimeZone;
extern NSString* const HEMAnalyticsEventTimeZoneChanged;
extern NSString* const HEMAnalyticsEventPropTZ;

// device management
extern NSString* const kHEMAnalyticsEventDeviceAction;
extern NSString* const kHEMAnalyticsEventDeviceActionFactoryRestore;
extern NSString* const kHEMAnalyticsEventDeviceActionPairingMode;
extern NSString* const kHEMAnalyticsEventDeviceActionUnpairSense;
extern NSString* const kHEMAnalyticsEventDeviceActionUnpairPill;

// timeline
extern NSString* const HEMAnalyticsEventTimelineBarLongPress;
extern NSString* const kHEMAnalyticsEventTimeline;
extern NSString* const kHEMAnalyticsEventTimelineChanged;
extern NSString* const kHEMAnalyticsEventTimelineAction;
extern NSString* const kHEMAnalyticsEventTimelineOpen;
extern NSString* const kHEMAnalyticsEventTimelineClose;
extern NSString* const HEMAnalyticsEventSleepScoreBreakdown;
extern NSString* const HEMAnalyticsEventTimelineZoomOut;
extern NSString* const HEMAnalyticsEventTimelineZoomIn;
extern NSString* const HEMAnalyticsEventTimelineAdjustTime;
extern NSString* const HEMAnalyticsEventTimelineAdjustTimeFailed;
extern NSString* const HEMAnalyticsEventTimelineDataRequest;
extern NSString* const HEMAnalyticsEventTimelineAlarmShortcut;

// alarms
extern NSString* const kHEMAnalyticsEventAlarms;
extern NSString* const HEMAnalyticsEventCreateNewAlarm;
extern NSString* const HEMAnalyticsEventSwitchSmartAlarm;
extern NSString* const HEMAnalyticsEventSwitchSmartAlarmOn;
extern NSString* const HEMAnalyticsEventSaveAlarm;
extern NSString* const HEMAnalyticsEventSaveAlarmHour;
extern NSString* const HEMAnalyticsEventSaveAlarmMinute;
extern NSString* const HEMAnalyticsEventSaveAlarmError;

// system alerts
extern NSString* const HEMAnalyticsEventSystemAlert;
extern NSString* const HEMAnalyticsEventSystemAlertAction;
extern NSString* const HEMAnalyticsEventSysAlertActionLater;
extern NSString* const HEMAnalyticsEventSysAlertActionNow;

@interface HEMAnalytics : NSObject

+ (void)trackSignUpWithName:(NSString*)userName;
+ (void)trackUserSession;
+ (void)updateGender:(SENAccountGender)gender;

@end