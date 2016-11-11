//
//  HEMSenseSettingsDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 11/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseWiFiStatus.h>
#import <SenseKit/SENAPITimeZone.h>
#import <SenseKit/SENPillMetadata.h>

#import "NSMutableAttributedString+HEMFormat.h"
#import "NSDate+HEMRelative.h"
#import "UIFont+HEMStyle.h"

#import "HEMSenseSettingsDataSource.h"
#import "HEMDeviceWarning.h"

@interface HEMSenseSettingsDataSource()

@property (nonatomic, strong) NSMutableOrderedSet<HEMDeviceWarning*>* warnings;
@property (nonatomic, strong) id disconnectObserverId;
@property (nonatomic, copy)   HEMSenseSettingsDisconnectBlock disconnectHandler;

@end

@implementation HEMSenseSettingsDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        _warnings = [NSMutableOrderedSet new];
    }
    return self;
}

#pragma mark - BLE

- (void)connectAndGetWiFiStatus:(void(^)(SENSenseWiFiStatus* wiFiStatus))completion {
    [SENSenseManager whenBleStateAvailable:^(BOOL on) {
        if (!on) {
            completion (nil);
            return;
        }
        
        SENServiceDevice* service = [SENServiceDevice sharedService];
        [service getConfiguredWiFi:^(NSString *ssid, SENSenseWiFiStatus *status, NSError *error) {
            if (error) {
                if ([[error domain] isEqualToString:SENServiceDeviceErrorDomain]) {
                    switch ([error code]) {
                        case SENServiceDeviceErrorSenseUnavailable:
                        case SENServiceDeviceErrorBLEUnavailable:
                            // ignore the above codes since these are expected
                            // use cases that generate such codes
                            break;
                        default:
                            [SENAnalytics trackError:error];
                            break;
                    }
                } else {
                    [SENAnalytics trackError:error];
                }
            }
            completion (status);
        }];
    }];
}

- (BOOL)isConnectedToSense {
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    return [[deviceService senseManager] isConnected];
}

- (void)enablePairingMode:(HEMSenseSettingsActionBlock)completion {
    [self watchForBLEDisconnects];
    
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceActionPairingMode}];
    
    [[SENServiceDevice sharedService] putSenseIntoPairingMode:^(NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (error);
    }];
}

- (NSString*)factoryResetMessageFromDeviceServiceError:(NSError*)error {
    switch ([error code]) {
        case SENServiceDeviceErrorUnlinkPillFromAccount:
            return NSLocalizedString(@"settings.factory-restore.error.unlink-pill", nil);
        case SENServiceDeviceErrorUnlinkSenseFromAccount:
            return NSLocalizedString(@"settings.factory-restore.error.unlink-sense", nil);
        case SENServiceDeviceErrorInProgress:
            return NSLocalizedString(@"settings.sense.busy", nil);
        case SENServiceDeviceErrorSenseUnavailable: {
            return NSLocalizedString(@"settings.sense.no-sense-message", nil);
        }
        default:
            return NSLocalizedString(@"settings.factory-restore.error.general-failure", nil);
    }
}

- (NSString*)factoryResetMessageFromBluetoothError:(NSError*)error {
    switch ([error code]) {
        case SENSenseManagerErrorCodeTimeout:
            return NSLocalizedString(@"settings.factory-restore.error.ble-timeout", nil);
        default:
            return NSLocalizedString(@"settings.factory-restore.error.general-ble-failure", nil);
    }
}

- (void)factoryReset:(HEMSenseSettingsDisconnectBlock)completion {
    [self watchForBLEDisconnects];
    
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    SENSenseMetadata* senseMetadata = [[deviceService devices] senseMetadata];
    SENDeviceMetadata* pillMetdata = [[deviceService devices] pillMetadata];
    NSString* senseId = [senseMetadata uniqueId];
    NSString* pillId = [pillMetdata uniqueId];
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceActionFactoryRestore,
                          kHEMAnalyticsEventPropSenseId : senseId ?: @"unknown",
                          kHEMAnalyticsEventPropPillId : pillId ?: @"unknown"}];
    
    __weak typeof(self) weakSelf = self;
    [deviceService restoreFactorySettings:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSError* translatedError = nil;
        
        if (error) {
            [SENAnalytics trackError:error];
            
            NSString* localizedMessage = nil;
            if ([[error domain] isEqualToString:SENServiceDeviceErrorDomain]) {
                localizedMessage = [strongSelf factoryResetMessageFromDeviceServiceError:error];
            } else {
                localizedMessage = [strongSelf factoryResetMessageFromBluetoothError:error];
            }
            
            NSMutableDictionary* info = [[error userInfo] mutableCopy];
            [info setValue:localizedMessage forKey:NSLocalizedDescriptionKey];
            translatedError = [NSError errorWithDomain:[error domain]
                                                  code:[error code]
                                              userInfo:info];
        }
        
        completion (translatedError);
    }];
}

- (void)watchForBLEDisconnects {
    if ([self disconnectObserverId]) {
        return;
    }
    
    SENSenseManager* manager = [[SENServiceDevice sharedService] senseManager];
    __weak typeof(self) weakSelf = self;
    self.disconnectObserverId =
    [manager observeUnexpectedDisconnect:^(NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        if ([weakSelf disconnectHandler]) {
            [weakSelf disconnectHandler] (error);
        }
    }];
}

#pragma mark - API

- (void)unlinkSense:(HEMSenseSettingsActionBlock)completion {
    SENSenseMetadata* senseMetadata = [[[SENServiceDevice sharedService] devices] senseMetadata];
    NSString* senseId = [senseMetadata uniqueId];
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceActionUnpairSense,
                          kHEMAnalyticsEventPropSenseId : senseId ?: @"unknown"}];
    
    [[SENServiceDevice sharedService] unlinkSenseFromAccount:^(NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (error);
    }];
}

- (void)updateToLocalTimeZone:(nonnull HEMSenseSettingsActionBlock)completion {
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [SENAPITimeZone setTimeZone:timeZone completion:^(id data, NSError *error) {
        if (!error) {
            NSString* tz = [timeZone name] ?: @"unknown";
            [SENAnalytics track:HEMAnalyticsEventTimeZoneChanged
                     properties:@{HEMAnalyticsEventPropTZ : tz}];
        } else {
            [SENAnalytics trackError:error];
        }
        completion (error);
    }];
}

#pragma mark - Warnings

- (nonnull NSOrderedSet*)deviceWarnings {
    return [self warnings];
}

- (NSAttributedString*)attributedWarningMessageForLastSeen:(NSDate*)lastSeenDate {
    NSString* format = NSLocalizedString(@"settings.sense.warning.last-seen-format", nil);
    NSString* lastSeen = [lastSeenDate timeAgo];
    lastSeen = lastSeen ?: NSLocalizedString(@"settings.device.warning.last-seen-generic", nil);
    
    NSAttributedString* attrLastSeen = [[NSAttributedString alloc] initWithString:lastSeen];
    
    NSMutableAttributedString* attrWarning =
    [[NSMutableAttributedString alloc] initWithFormat:format args:@[attrLastSeen]];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    
    return attrWarning;
}

- (NSAttributedString*)attributedWarningForMessage:(NSString*)message {
    NSMutableAttributedString* attrWarning = [[NSMutableAttributedString alloc] initWithString:message];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    return attrWarning;
}


- (NSAttributedString*)attributedSenseNotConnectedWarning {
    NSString* message = NSLocalizedString(@"settings.sense.warning.not-connected-sense", nil);
    return [self attributedWarningForMessage:message];
}


- (NSAttributedString*)attributedWiFiWarning {
    NSString* message = NSLocalizedString(@"settings.sense.warning.wifi", nil);
    return [self attributedWarningForMessage:message];
}

- (void)checkForWarnings:(HEMSenseSettingsWarningBlock)completion {
    __weak typeof(self) weakSelf = self;
    
    [self connectAndGetWiFiStatus:^(SENSenseWiFiStatus *wiFiStatus) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [[strongSelf warnings] removeAllObjects];
        
        SENServiceDevice* deviceService = [SENServiceDevice sharedService];
        SENSenseMetadata* senseMetdata = [[deviceService devices] senseMetadata];
        BOOL connected = [[deviceService senseManager] isConnected];
        
        if ([deviceService shouldWarnAboutLastSeenForDevice:senseMetdata]) {
            NSString* summary = NSLocalizedString(@"settings.sense.warning.summary.last-seen", nil);
            NSString* support = NSLocalizedString(@"help.url.slug.sense-not-seen", nil);
            NSAttributedString* message = [strongSelf attributedWarningMessageForLastSeen:[senseMetdata lastSeenDate]];
            [[strongSelf warnings] addObject:[[HEMDeviceWarning alloc] initWithType:HEMDeviceWarningTypeLastSeen
                                                                            summary:summary
                                                                            message:message
                                                                        supportPage:support]];
        }
        
        if (!connected) {
            NSString* summary = NSLocalizedString(@"settings.sense.warning.summary.not-connected-ble", nil);
            NSString* support = NSLocalizedString(@"help.url.slug.sense-not-connected", nil);
            NSAttributedString* message = [strongSelf attributedSenseNotConnectedWarning];
            [[strongSelf warnings] addObject:[[HEMDeviceWarning alloc] initWithType:HEMDeviceWarningTypeSenseNotConnectedOverBLE
                                                                            summary:summary
                                                                            message:message
                                                                        supportPage:support]];
        } else if (![wiFiStatus isConnected]) {
            NSString* summary = NSLocalizedString(@"settings.sense.warning.summary.wifi", nil);
            NSString* support = NSLocalizedString(@"help.url.slug.sense-no-internet", nil);
            NSAttributedString* message = [strongSelf attributedWiFiWarning];
            [[strongSelf warnings] addObject:[[HEMDeviceWarning alloc] initWithType:HEMDeviceWarningTypeSenseLostServerConnection
                                                                            summary:summary
                                                                            message:message
                                                                        supportPage:support]];
        }
        
        completion ([strongSelf warnings]);
    }];
}

- (BOOL)clearWiFiWarnings {
    if ([[self warnings] count] == 0) {
        return NO;
    }

    NSMutableOrderedSet* updatedWarnings = [[NSMutableOrderedSet alloc] initWithCapacity:[[self warnings] count]];
    for (HEMDeviceWarning* warning in [self warnings]) {
        if ([warning type] != HEMDeviceWarningTypeSenseLostServerConnection) {
            [updatedWarnings addObject:warning];
        }
    }

    BOOL updated = [updatedWarnings count] < [[self warnings] count];
    [self setWarnings:updatedWarnings];
    return updated;
}

#pragma mark - Clean up

- (void)dealloc {
    SENSenseManager* manager = [[SENServiceDevice sharedService] senseManager];
    if (_disconnectObserverId) {
        [manager removeUnexpectedDisconnectObserver:_disconnectObserverId];
    }
    [manager disconnectFromSense];
}

@end
