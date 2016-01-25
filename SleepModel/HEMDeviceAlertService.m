//
//  HEMDeviceAlertService.m
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENAPIDevice.h>
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENPillMetadata.h>

#import <SenseKit/SENServiceDevice.h>

#import "NSDate+HEMRelative.h"

#import "HEMDeviceAlertService.h"
#import "HEMOnboardingService.h"

static NSInteger const HEMDeviceAlertLastSeenThresholdInDays = 1;
static NSInteger const HEMDeviceAlertPillLowBatteryAlertThresholdInDays = 1;
static NSInteger const HEMDeviceAlertMaxLastSeenAlertsInDays = 1;
static NSString* const HEMDeviceAlertPrefPillLowBatteryLastAlert = @"HEMDeviceAlertPrefPillLowBatteryLastAlert";
static NSString* const HEMDeviceAlertPrefPillLastSeenLastAlert = @"HEMDeviceAlertPrefPillLastSeenLastAlert";
static NSString* const HEMDeviceAlertPrefSenseLastSeenLastAlert = @"HEMDeviceAlertPrefSenseLastSeenLastAlert";

@interface HEMDeviceAlertService()

@property (nonatomic, strong) NSMutableArray* changeObserverCallbacks;

@end

@implementation HEMDeviceAlertService

- (void)checkDeviceState:(HEMDeviceAlertStateCallback)completion {
    if (![SENAuthorizationService isAuthorized]) {
        completion (HEMDeviceAlertStateUnknown);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPIDevice getPairedDevices:^(SENPairedDevices* devices, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [SENAnalytics trackError:error];
            completion (HEMDeviceAlertStateUnknown);
            return;
        }
        
        completion ([strongSelf determineDeviceStateFromDevices:devices]);
        
    }];
}

- (HEMDeviceAlertState)determineDeviceStateFromDevices:(SENPairedDevices*)devices {
    if (![devices hasPairedSense]) {
        
        return HEMDeviceAlertStateSenseNotPaired;
        
    } else if ([self shouldShowDeviceHasNotBeenSeen:[devices senseMetadata]]) {
        
        return HEMDeviceAlertStateSenseNotSeen;
        
    } else if (![devices hasPairedPill]) {
        
        return HEMDeviceAlertStatePillNotPaired;
        
    } else if ([self isBatteryStillLow:[devices pillMetadata]]) {

        return HEMDeviceAlertStatePillLowBattery;
        
    } else if ([self shouldShowDeviceHasNotBeenSeen:[devices pillMetadata]]) {
        
        return HEMDeviceAlertStatePillNotSeen;
        
    } else {
        
        return HEMDeviceAlertStateNormal;
        
    }
}

- (void)updateLastAlertShownForState:(HEMDeviceAlertState)state {
    switch (state) {
        case HEMDeviceAlertStatePillLowBattery:
            [self updateLastAlertDateForKey:HEMDeviceAlertPrefPillLowBatteryLastAlert];
            break;
        case HEMDeviceAlertStatePillNotSeen:
            [self updateLastAlertDateForKey:HEMDeviceAlertPrefPillLastSeenLastAlert];
            break;
        case HEMDeviceAlertStateSenseNotSeen:
            [self updateLastAlertDateForKey:HEMDeviceAlertPrefSenseLastSeenLastAlert];
            break;
        default:
            break;
    }
}

- (void)updateLastAlertDateForKey:(NSString*)key {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    [localPrefs setUserPreference:[NSDate date] forKey:key];
}

- (BOOL)isBatteryStillLow:(SENPillMetadata*)pillMetadata {
    if ([pillMetadata state] != SENPillStateLowBattery) {
        return NO;
    }
    
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    NSDate* lastLowBatteryAlertDate = [localPrefs userPreferenceForKey:HEMDeviceAlertPrefPillLowBatteryLastAlert];
    return !lastLowBatteryAlertDate
        || [lastLowBatteryAlertDate daysElapsed] >= HEMDeviceAlertPillLowBatteryAlertThresholdInDays;
}

- (BOOL)shouldShowDeviceHasNotBeenSeen:(SENDeviceMetadata*)metadata {
    if ([[metadata lastSeenDate] daysElapsed] < HEMDeviceAlertLastSeenThresholdInDays) {
        return NO;
    }
    
    NSString* lastSeenPrefKey = nil;
    if ([metadata isKindOfClass:[SENSenseMetadata class]]) {
        lastSeenPrefKey = HEMDeviceAlertPrefSenseLastSeenLastAlert;
    } else {
        lastSeenPrefKey = HEMDeviceAlertPrefPillLastSeenLastAlert;
    }
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    NSDate* lastSeenAlertDate = [localPrefs userPreferenceForKey:lastSeenPrefKey];
    return !lastSeenAlertDate
        || [lastSeenAlertDate daysElapsed] >= HEMDeviceAlertMaxLastSeenAlertsInDays;
}

#pragma mark - Pairing changes

- (void)listenForPairingChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(devicesCleared)
                   name:SENServiceDeviceNotificationFactorySettingsRestored
                 object:nil];
    [center addObserver:self
               selector:@selector(pillPaired)
                   name:HEMOnboardingNotificationDidChangePillPairing
                 object:nil];
    [center addObserver:self
               selector:@selector(sensePaired)
                   name:HEMOnboardingNotificationDidChangeSensePairing
                 object:nil];
    [center addObserver:self
               selector:@selector(senseUnpaired)
                   name:SENServiceDeviceNotificationSenseUnpaired
                 object:nil];
    [center addObserver:self
               selector:@selector(pillUnpaired)
                   name:SENServiceDeviceNotificationPillUnpaired
                 object:nil];
}

- (void)notifyObserversWithChange:(HEMDeviceChange)change {
    for (HEMDeviceAlertChangeCallback cb in [self changeObserverCallbacks]) {
        cb (change);
    }
}

- (void)observeDeviceChanges:(HEMDeviceAlertChangeCallback)changeCallback {
    if (![self changeObserverCallbacks]) {
        [self listenForPairingChanges];
        [self setChangeObserverCallbacks:[NSMutableArray array]];
    }
    [[self changeObserverCallbacks] addObject:[changeCallback copy]];
}

- (void)devicesCleared {
    [self notifyObserversWithChange:HEMDeviceChangePillUnpaired | HEMDeviceChangeSenseUnpaired];
}

- (void)senseUnpaired {
    [self notifyObserversWithChange:HEMDeviceChangeSenseUnpaired];
}

- (void)pillUnpaired {
    [self notifyObserversWithChange:HEMDeviceChangePillUnpaired];
}

- (void)sensePaired {
    [self notifyObserversWithChange:HEMDeviceChangeSensePaired];
}

- (void)pillPaired {
    [self notifyObserversWithChange:HEMDeviceChangePillPaired];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
