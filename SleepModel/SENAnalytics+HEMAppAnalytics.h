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

NS_ASSUME_NONNULL_BEGIN
// general
extern NSString* const kHEMAnalyticsEventWarning;
extern NSString* const kHEMAnalyticsEventHelp;
extern NSString* const kHEMAnalyticsEventVideo;
extern NSString* const kHEMAnalyticsEventPropMessage;
extern NSString* const kHEMAnalyticsEventPropAction;
extern NSString* const kHEMAnalyticsEventPropDate;
extern NSString* const kHEMAnalyticsEventPropType;
extern NSString* const kHEMAnalyticsEventPropPlatform;
extern NSString* const kHEMAnalyticsEventPlatform;
extern NSString* const kHEMAnalyticsEventPropGender;
extern NSString* const kHEMAnalyticsEventPropAccount;
extern NSString* const kHEMAnalyticsEventPropSenseId;
extern NSString* const kHEMAnalyticsEventPropPillId;
extern NSString* const kHEMAnalyticsEventPropHealthKit;
extern NSString* const kHEMAnalyticsEventPropSSID;
extern NSString* const kHEMAnalyticsEventPropPassLength;

// permissions
extern NSString* const kHEMAnalyticsEventPermissionLoc;
extern NSString* const kHEManaltyicsEventPropStatus;
extern NSString* const kHEManaltyicsEventStatusSkipped;
extern NSString* const kHEManaltyicsEventStatusEnabled;
extern NSString* const kHEManaltyicsEventStatusDenied;
extern NSString* const kHEManaltyicsEventStatusDisabled;
extern NSString* const kHEManaltyicsEventStatusNotSupported;

// onboarding
extern NSString* const HEMAnalyticsEventWelcomeIntroSwipe;
extern NSString* const HEMAnalyticsEventPropScreen;
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
extern NSString* const HEMAnalyticsEventOnbStart;
extern NSString* const HEMAnalyticsEventHealth;
extern NSString* const HEMAnalyticsEventAccount;
extern NSString* const HEMAnalyticsEventLocation;
extern NSString* const HEMAnalyticsEventNotification;
extern NSString* const HEMAnalyticsEventNoBle;
extern NSString* const HEMAnalyticsEventAudio;
extern NSString* const HEMAnalyticsEventSleepPill;
extern NSString* const HEMAnalyticsEventPillPlacement;
extern NSString* const HEMAnalyticsEventPairingMode;
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
extern NSString* const HEMAnalyticsEventSensePaired;
extern NSString* const HEMAnalyticsEventWiFi;
extern NSString* const HEMAnalyticsEventWiFiConnectionUpdate;
extern NSString* const HEMAnalyticsEventPropWiFiStatus;
extern NSString* const HEMAnalyticsEventPropHttpCode;
extern NSString* const HEMAnalyticsEventPropSocketCode;
extern NSString* const HEMAnalyticsEventWiFiScan;
extern NSString* const HEMAnalyticsEventWiFiRescan;
extern NSString* const HEMAnalyticsEventWiFiPass;
extern NSString* const HEMAnalyticsEventWiFiSubmit;
extern NSString* const HEMAnalyticsEventPairPill;
extern NSString* const HEMAnalyticsEventPillPaired;
extern NSString* const HEMAnalyticsEventPairPillRetry;


// main
extern NSString* const kHEMAnalyticsEventAppLaunched;
extern NSString* const kHEMAnalyticsEventAppClosed;
extern NSString* const kHEMAnalyticsEventPropEvent;
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
extern NSString* const HEMAnalyticsEventHealthSync;

// tell a friend
extern NSString* const HEMAnalyticsEventTellAFriendTapped;
extern NSString* const HEMAnalyticsEventTellAFriendCompleted;
extern NSString* const HEMAnalyticsEventTellAFriendCompletedPropType;

// back view
NSString* const HEMAnalyticsEventBackViewSwipe;
NSString* const HEMAnalyticsEventBackViewTapped;

// support
extern NSString* const HEMAnalyticsEventSupport;
extern NSString* const HEMAnalyticsEventSupportContactUs;
extern NSString* const HEMAnalyticsEventSupportTickets;
extern NSString* const HEMAnalyticsEventSupportUserGuide;
extern NSString* const HEMAnalyticsEventSupportTicketSubmitted;

// authentication
extern NSString* const kHEMAnalyticsEventSignInStart;
extern NSString* const kHEMAnalyticsEventSignIn;
extern NSString* const kHEMAnalyticsEventSignOut;

// time zone
extern NSString* const HEMAnalyticsEventTimeZone;
extern NSString* const HEMAnalyticsEventTimeZoneChanged;
extern NSString* const HEMAnalyticsEventPropTZ;
extern NSString* const HEMAnalyticsEventMissingTZMapping;

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
extern NSString* const kHEMAnalyticsEventTimelineAdjustTimeSaved;
extern NSString* const HEMAnalyticsEventTimelineEventCorrect;
extern NSString* const HEMAnalyticsEventTimelineEventIncorrect;
extern NSString* const HEMAnalyticsEventTimelineAdjustTimeFailed;
extern NSString* const HEMAnalyticsEventTimelineDataRequest;
extern NSString* const HEMAnalyticsEventTimelineAlarmShortcut;

// alarms
extern NSString* const kHEMAnalyticsEventAlarms;
extern NSString* const HEMAnalyticsEventCreateNewAlarm;
extern NSString* const HEMAnalyticsEventDeleteAlarm;
extern NSString* const HEMAnalyticsEventSwitchSmartAlarm;
extern NSString* const HEMAnalyticsEventAlarmOnOff;
extern NSString* const HEMAnalyticsEventPropDaysRepeated;
extern NSString* const HEMAnalyticsEventPropEnabled;
extern NSString* const HEMAnalyticsEventPropIsSmart;
extern NSString* const HEMAnalyticsEventSwitchSmartAlarmOn;
extern NSString* const HEMAnalyticsEventSaveAlarm;
extern NSString* const HEMAnalyticsEventPropHour;
extern NSString* const HEMAnalyticsEventPropMinute;

// system alerts
extern NSString* const HEMAnalyticsEventSystemAlert;
extern NSString* const HEMAnalyticsEventSystemAlertAction;
extern NSString* const HEMAnalyticsEventSysAlertActionLater;
extern NSString* const HEMAnalyticsEventSysAlertActionNow;

// app review
extern NSString* const HEMAnalyticsEventAppReviewShown;
extern NSString* const HEMAnalyticsEventAppReviewStart;
extern NSString* const HEMAnalyticsEventAppReviewEnjoySense;
extern NSString* const HEMAnalyticsEventAppReviewDoNotEnjoySense;
extern NSString* const HEMAnalyticsEventAppReviewHelp;
extern NSString* const HEMAnalyticsEventAppReviewRate;
extern NSString* const HEMAnalyticsEventAppReviewRateNoAsk;
extern NSString* const HEMAnalyticsEventAppReviewFeedback;
extern NSString* const HEMAnalyticsEventAppReviewDone;
extern NSString* const HEMAnalyticsEventAppReviewSkip;

@interface SENAnalytics (HEMAppAnalytics)

+ (void)enableAnalytics;
+ (void)trackSignUpOfNewAccount:(SENAccount*)account;
+ (void)trackUserSession:(nullable SENAccount*)account;
+ (void)trackUserSession:(nullable SENAccount *)account
              properties:(nullable NSDictionary<NSString*, NSString*>*)properties;
+ (void)trackErrorWithMessage:(NSString*)message;
+ (void)trackWarningWithMessage:(NSString*)message;
+ (void)trackError:(NSError*)error;
+ (void)updateEmail:(NSString*)email;
+ (void)trackAlarmSave:(SENAlarm*)alarm;
+ (void)trackAlarmToggle:(SENAlarm*)alarm;

@end

NS_ASSUME_NONNULL_END