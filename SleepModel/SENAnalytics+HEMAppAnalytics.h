//
//  SENAnalytics+HEMAppAnalytics.h
//  Sense
//
//  Created by Jimmy Lu on 7/23/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <SenseKit/SENAnalytics.h>
#import <SenseKit/SENAccount.h>

@class  SENAlarm;

// general
extern NSString* _Nonnull const kHEMAnalyticsEventWarning;
extern NSString* _Nonnull const kHEMAnalyticsEventHelp;
extern NSString* _Nonnull const kHEMAnalyticsEventVideo;
extern NSString* _Nonnull const kHEMAnalyticsEventPropMessage;
extern NSString* _Nonnull const kHEMAnalyticsEventPropAction;
extern NSString* _Nonnull const kHEMAnalyticsEventPropDate;
extern NSString* _Nonnull const kHEMAnalyticsEventPropType;
extern NSString* _Nonnull const kHEMAnalyticsEventPropPlatform;
extern NSString* _Nonnull const kHEMAnalyticsEventPlatform;
extern NSString* _Nonnull const kHEMAnalyticsEventPropGender;
extern NSString* _Nonnull const kHEMAnalyticsEventPropAccount;
extern NSString* _Nonnull const kHEMAnalyticsEventPropSenseId;
extern NSString* _Nonnull const kHEMAnalyticsEventPropPillId;
extern NSString* _Nonnull const kHEMAnalyticsEventPropHealthKit;
extern NSString* _Nonnull const kHEMAnalyticsEventPropSSID;
extern NSString* _Nonnull const kHEMAnalyticsEventPropPassLength;

// permissions
extern NSString* _Nonnull const kHEMAnalyticsEventPermissionLoc;
extern NSString* _Nonnull const kHEManaltyicsEventPropStatus;
extern NSString* _Nonnull const kHEManaltyicsEventStatusSkipped;
extern NSString* _Nonnull const kHEManaltyicsEventStatusEnabled;
extern NSString* _Nonnull const kHEManaltyicsEventStatusDenied;
extern NSString* _Nonnull const kHEManaltyicsEventStatusDisabled;
extern NSString* _Nonnull const kHEManaltyicsEventStatusNotSupported;

// onboarding
extern NSString* _Nonnull const HEMAnalyticsEventWelcomeIntroSwipe;
extern NSString* _Nonnull const HEMAnalyticsEventPropScreen;
extern NSString* _Nonnull const HEMAnalyticsEventOnboardingPrefix;
extern NSString* _Nonnull const kHEMAnalyticsEventOnBNoSense;
extern NSString* _Nonnull const kHEMAnalyticsEventOnBHelp;
extern NSString* _Nonnull const kHEMAnalyticsEventPropStep;
extern NSString* _Nonnull const kHEMAnalyticsEventPropBluetooth;
extern NSString* _Nonnull const kHEMAnalyticsEventPropAudio;
extern NSString* _Nonnull const kHEMAnalyticsEventPropSensePairingMode;
extern NSString* _Nonnull const kHEMAnalyticsEventPropSensePairing;
extern NSString* _Nonnull const kHEMAnalyticsEventPropSenseSetup;
extern NSString* _Nonnull const kHEMAnalyticsEventPropWiFiScan;
extern NSString* _Nonnull const kHEMAnalyticsEventPropWiFiPass;
extern NSString* _Nonnull const kHEMAnalyticsEventPropSecurityType;
extern NSString* _Nonnull const kHEMAnalyticsEventPropWiFiOther;
extern NSString* _Nonnull const kHEMAnalyticsEventPropWiFiRSSI;
extern NSString* _Nonnull const kHEMAnalyticsEventPropPillPairing;
extern NSString* _Nonnull const kHEMAnalyticsEventPropPillPlacement;
extern NSString* _Nonnull const kHEMAnalyticsEventPropPillAnother;
extern NSString* _Nonnull const HEMAnalyticsEventOnbStart;
extern NSString* _Nonnull const HEMAnalyticsEventHealth;
extern NSString* _Nonnull const HEMAnalyticsEventAccount;
extern NSString* _Nonnull const HEMAnalyticsEventLocation;
extern NSString* _Nonnull const HEMAnalyticsEventNotification;
extern NSString* _Nonnull const HEMAnalyticsEventNoBle;
extern NSString* _Nonnull const HEMAnalyticsEventAudio;
extern NSString* _Nonnull const HEMAnalyticsEventSleepPill;
extern NSString* _Nonnull const HEMAnalyticsEventPillPlacement;
extern NSString* _Nonnull const HEMAnalyticsEventAnotherPill;
extern NSString* _Nonnull const HEMAnalyticsEventPairingMode;
extern NSString* _Nonnull const HEMAnalyticsEventGetApp;
extern NSString* _Nonnull const HEMAnalyticsEventSenseColors;
extern NSString* _Nonnull const HEMAnalyticsEventFirstAlarm;
extern NSString* _Nonnull const HEMAnalyticsEventRoomCheck;
extern NSString* _Nonnull const HEMAnalyticsEventOnbEnd;
extern NSString* _Nonnull const HEMAnalyticsEventSkip;
extern NSString* _Nonnull const kHEMAnalyticsEventPropOnBScreen;
extern NSString* _Nonnull const kHEMAnalyticsEventPropScreenPillPairing;
extern NSString* _Nonnull const HEMAnalyticsEventBirthday;
extern NSString* _Nonnull const HEMAnalyticsEventGender;
extern NSString* _Nonnull const HEMAnalyticsEventHeight;
extern NSString* _Nonnull const HEMAnalyticsEventWeight;
extern NSString* _Nonnull const HEMAnalyticsEventSenseSetup;
extern NSString* _Nonnull const HEMAnalyticsEventPairSense;
extern NSString* _Nonnull const HEMAnalyticsEventWiFi;
extern NSString* _Nonnull const HEMAnalyticsEventWiFiConnectionUpdate;
extern NSString* _Nonnull const HEMAnalyticsEventPropWiFiStatus;
extern NSString* _Nonnull const HEMAnalyticsEventPropHttpCode;
extern NSString* _Nonnull const HEMAnalyticsEventPropSocketCode;
extern NSString* _Nonnull const HEMAnalyticsEventWiFiScan;
extern NSString* _Nonnull const HEMAnalyticsEventWiFiRescan;
extern NSString* _Nonnull const HEMAnalyticsEventWiFiPass;
extern NSString* _Nonnull const HEMAnalyticsEventWiFiSubmit;
extern NSString* _Nonnull const HEMAnalyticsEventPairPill;
extern NSString* _Nonnull const HEMAnalyticsEventPairPillRetry;


// main
extern NSString* _Nonnull const kHEMAnalyticsEventAppLaunched;
extern NSString* _Nonnull const kHEMAnalyticsEventAppClosed;
extern NSString* _Nonnull const kHEMAnalyticsEventPropEvent;
extern NSString* _Nonnull const kHEMAnalyticsEventSettings;
extern NSString* _Nonnull const kHEMAnalyticsEventTrends;
extern NSString* _Nonnull const kHEMAnalyticsEventCurrentConditions;
extern NSString* _Nonnull const kHEMAnalyticsEventFeed;
extern NSString* _Nonnull const kHEMAnalyticsEventQuestion;
extern NSString* _Nonnull const kHEMAnalyticsEventAccount;
extern NSString* _Nonnull const kHEMAnalyticsEventInsight;
extern NSString* _Nonnull const kHEMAnalyticsEventDevices;
extern NSString* _Nonnull const kHEMAnalyticsEventUnitsNTime;
extern NSString* _Nonnull const kHEMAnalyticsEventSensor;
extern NSString* _Nonnull const kHEMAnalyticsEventPropSensorName;
extern NSString* _Nonnull const kHEMAnalyticsEventSense;
extern NSString* _Nonnull const kHEMAnalyticsEventPill;
extern NSString* _Nonnull const HEMAnalyticsEventHealthSync;

// tell a friend
extern NSString* _Nonnull const HEMAnalyticsEventTellAFriendTapped;
extern NSString* _Nonnull const HEMAnalyticsEventTellAFriendCompleted;
extern NSString* _Nonnull const HEMAnalyticsEventTellAFriendCompletedPropType;

// back view
NSString* _Nonnull const HEMAnalyticsEventBackViewSwipe;
NSString* _Nonnull const HEMAnalyticsEventBackViewTapped;

// support
extern NSString* _Nonnull const HEMAnalyticsEventSupport;
extern NSString* _Nonnull const HEMAnalyticsEventSupportContactUs;
extern NSString* _Nonnull const HEMAnalyticsEventSupportTickets;
extern NSString* _Nonnull const HEMAnalyticsEventSupportUserGuide;
extern NSString* _Nonnull const HEMAnalyticsEventSupportTicketSubmitted;

// authentication
extern NSString* _Nonnull const kHEMAnalyticsEventSignInStart;
extern NSString* _Nonnull const kHEMAnalyticsEventSignIn;
extern NSString* _Nonnull const kHEMAnalyticsEventSignOut;

// time zone
extern NSString* _Nonnull const HEMAnalyticsEventTimeZone;
extern NSString* _Nonnull const HEMAnalyticsEventTimeZoneChanged;
extern NSString* _Nonnull const HEMAnalyticsEventPropTZ;

// device management
extern NSString* _Nonnull const kHEMAnalyticsEventDeviceAction;
extern NSString* _Nonnull const kHEMAnalyticsEventDeviceActionFactoryRestore;
extern NSString* _Nonnull const kHEMAnalyticsEventDeviceActionPairingMode;
extern NSString* _Nonnull const kHEMAnalyticsEventDeviceActionUnpairSense;
extern NSString* _Nonnull const kHEMAnalyticsEventDeviceActionUnpairPill;

// timeline
extern NSString* _Nonnull const HEMAnalyticsEventTimelineBarLongPress;
extern NSString* _Nonnull const kHEMAnalyticsEventTimeline;
extern NSString* _Nonnull const kHEMAnalyticsEventTimelineChanged;
extern NSString* _Nonnull const kHEMAnalyticsEventTimelineAction;
extern NSString* _Nonnull const kHEMAnalyticsEventTimelineOpen;
extern NSString* _Nonnull const kHEMAnalyticsEventTimelineClose;
extern NSString* _Nonnull const HEMAnalyticsEventSleepScoreBreakdown;
extern NSString* _Nonnull const HEMAnalyticsEventTimelineZoomOut;
extern NSString* _Nonnull const HEMAnalyticsEventTimelineZoomIn;
extern NSString* _Nonnull const HEMAnalyticsEventTimelineAdjustTime;
extern NSString* _Nonnull const kHEMAnalyticsEventTimelineAdjustTimeSaved;
extern NSString* _Nonnull const HEMAnalyticsEventTimelineEventCorrect;
extern NSString* _Nonnull const HEMAnalyticsEventTimelineEventIncorrect;
extern NSString* _Nonnull const HEMAnalyticsEventTimelineAdjustTimeFailed;
extern NSString* _Nonnull const HEMAnalyticsEventTimelineDataRequest;
extern NSString* _Nonnull const HEMAnalyticsEventTimelineAlarmShortcut;

// alarms
extern NSString* _Nonnull const kHEMAnalyticsEventAlarms;
extern NSString* _Nonnull const HEMAnalyticsEventCreateNewAlarm;
extern NSString* _Nonnull const HEMAnalyticsEventSwitchSmartAlarm;
extern NSString* _Nonnull const HEMAnalyticsEventAlarmOnOff;
extern NSString* _Nonnull const HEMAnalyticsEventPropDaysRepeated;
extern NSString* _Nonnull const HEMAnalyticsEventPropEnabled;
extern NSString* _Nonnull const HEMAnalyticsEventPropIsSmart;
extern NSString* _Nonnull const HEMAnalyticsEventSwitchSmartAlarmOn;
extern NSString* _Nonnull const HEMAnalyticsEventSaveAlarm;
extern NSString* _Nonnull const HEMAnalyticsEventPropHour;
extern NSString* _Nonnull const HEMAnalyticsEventPropMinute;

// system alerts
extern NSString* _Nonnull const HEMAnalyticsEventSystemAlert;
extern NSString* _Nonnull const HEMAnalyticsEventSystemAlertAction;
extern NSString* _Nonnull const HEMAnalyticsEventSysAlertActionLater;
extern NSString* _Nonnull const HEMAnalyticsEventSysAlertActionNow;

// app review
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewShown;
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewStart;
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewEnjoySense;
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewDoNotEnjoySense;
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewHelp;
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewRate;
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewRateNoAsk;
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewFeedback;
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewDone;
extern NSString* _Nonnull const HEMAnalyticsEventAppReviewSkip;

@interface SENAnalytics (HEMAppAnalytics)

+ (void)enableAnalytics;
+ (void)trackSignUpOfNewAccount:(nonnull SENAccount*)account;
+ (void)trackUserSession:(nullable SENAccount*)account;
+ (void)trackUserSession:(nullable SENAccount *)account
              properties:(nullable NSDictionary<NSString*, NSString*>*)properties;
+ (void)trackErrorWithMessage:(nonnull NSString*)message;
+ (void)trackWarningWithMessage:(nonnull NSString*)message;
+ (void)trackError:(nonnull NSError*)error;
+ (void)updateEmail:(nonnull NSString*)email;
+ (void)trackAlarmSave:(nonnull SENAlarm*)alarm;
+ (void)trackAlarmToggle:(nonnull SENAlarm*)alarm;

@end
