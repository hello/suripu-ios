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

#import "NSDate+HEMRelative.h"

#import "HEMDeviceAlertService.h"

static NSInteger const HEMDeviceAlertLastSeenThresholdInDays = 1;
static NSInteger const HEMDeviceAlertPillLowBatteryAlertThresholdInDays = 1;
static NSString* const HEMDeviceAlertPrefPillLowBatteryLastAlert = @"HEMDeviceAlertPrefPillLowBatteryLastAlert";

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
        
    } else if ([self isLastSeenTooLongAgo:[devices senseMetadata]]) {
        
        return HEMDeviceAlertStateSenseNotSeen;
        
    } else if (![devices hasPairedPill]) {
        
        return HEMDeviceAlertStatePillNotPaired;
        
    } else if ([self isBatteryIsStillLow:[devices pillMetadata]]) {

        return HEMDeviceAlertStatePillLowBattery;
        
    } else if ([self isLastSeenTooLongAgo:[devices pillMetadata]]) {
        
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
        default:
            break;
    }
}

- (void)updateLastAlertDateForKey:(NSString*)key {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    [localPrefs setUserPreference:[NSDate date] forKey:key];
}

- (BOOL)isBatteryIsStillLow:(SENPillMetadata*)pillMetadata {
    if ([pillMetadata state] != SENPillStateLowBattery) {
        return NO;
    }
    
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    NSDate* lastLowBatteryAlertDate = [localPrefs userPreferenceForKey:HEMDeviceAlertPrefPillLowBatteryLastAlert];
    return !lastLowBatteryAlertDate
        || [lastLowBatteryAlertDate daysElapsed] >= HEMDeviceAlertPillLowBatteryAlertThresholdInDays;
}

- (BOOL)isLastSeenTooLongAgo:(SENDeviceMetadata*)metadata {
    return [[metadata lastSeenDate] daysElapsed] >= HEMDeviceAlertLastSeenThresholdInDays;
}

@end
