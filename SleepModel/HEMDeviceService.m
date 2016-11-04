//
//  HEMDeviceService.m
//  Sense
//
//  Created by Jimmy Lu on 12/29/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import <LGBluetooth/LGBluetooth.h>

#import <SenseKit/SENSense.h>
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENDeviceMetadata.h>
#import <SenseKit/SENAPIDevice.h>
#import <SenseKit/SENPillMetadata.h>
#import <SenseKit/SENSleepPillManager.h>
#import <SenseKit/SENSleepPill.h>
#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENSwapStatus.h>
#import <SenseKit/SENSenseMetadata.h>

#import "HEMDeviceService.h"
#import "HEMConfig.h"
#import "NSDate+HEMRelative.h"

NSString* const HEMDeviceServiceErrorDomain = @"is.hello.app.service.device";

static NSString* const HEMDeviceSettingHwVersion = @"HEMDeviceSettingHwVersion";
static NSInteger const HEMPillDfuPillMinimumRSSI = -70;
static NSString* const HEMPillDfuPrefLastUpdate = @"HEMPillDfuPrefLastUpdate";
static NSUInteger const HEMPillDfuSuppressionReq = 2; // will not show dfu updates if done within the hour
static CGFloat const HEMPillDfuMinPhoneBattery = 0.2f;

@interface HEMDeviceService()

@property (nonatomic, strong) SENPairedDevices* devices;
@property (nonatomic, strong) SENSleepPillManager* pillManager;
@property (nonatomic, strong) SENSenseManager* senseManager;
@property (nonatomic, copy) HEMDeviceResetHandler resetHandler;
@property (nonatomic, copy) id senseDisconnectObserver;

@end

@implementation HEMDeviceService

- (instancetype)init {
    self = [super init];
    if (self) {
        _devices = [[SENServiceDevice sharedService] devices]; // in case already loaded
        [self listenForDeprecatedServiceNotifications];
    }
    return self;
}

- (void)listenForDeprecatedServiceNotifications {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(clearDevicesCache)
                   name:SENServiceDeviceNotificationFactorySettingsRestored
                 object:nil];
    [center addObserver:self
               selector:@selector(clearDevicesCache)
                   name:SENServiceDeviceNotificationSenseUnpaired
                 object:nil];
    [center addObserver:self
               selector:@selector(clearDevicesCache)
                   name:SENServiceDeviceNotificationPillUnpaired
                 object:nil];
}

- (void)clearDevicesCache {
    [self setDevices:nil];
}

- (NSError*)errorWithCode:(HEMDeviceError)code {
    return [NSError errorWithDomain:HEMDeviceServiceErrorDomain
                               code:code
                           userInfo:nil];
}

- (void)refreshMetadata:(HEMDeviceMetadataHandler)completion {
    __weak typeof(self) weakSelf = self;
    [[SENServiceDevice sharedService] loadDeviceInfo:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        SENPairedDevices* devices = nil;
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            devices = [[SENServiceDevice sharedService] devices];
            [strongSelf saveHardwareVersion:[devices senseMetadata]];
            [strongSelf setDevices:devices];
        }
        
        if (completion) {
            completion (devices, error);
        }
    }];
}

- (void)saveHardwareVersion:(SENSenseMetadata*)senseMetadata {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    NSNumber* version = @([senseMetadata hardwareVersion]);
    [localPrefs setUserPreference:version forKey:HEMDeviceSettingHwVersion];
}

- (SENSenseHardware)savedHardwareVersion {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    NSNumber* versionValue = [localPrefs userPreferenceForKey:HEMDeviceSettingHwVersion];
    return versionValue ? [versionValue unsignedIntegerValue] : SENSenseHardwareUnknown;
}

- (BOOL)shouldWarnAboutLastSeenForDevice:(SENDeviceMetadata*)metadata {
    if (![metadata lastSeenDate]) {
        return NO;
    }
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [NSDateComponents new];
    components.day = -1;
    
    NSDate* dayOld = [calendar dateByAddingComponents:components
                                               toDate:[NSDate date]
                                              options:0];
    return [[metadata lastSeenDate] compare:dayOld] == NSOrderedAscending;
}

- (BOOL)isBleStateAvailable {
    LGCentralManager* central = [LGCentralManager sharedInstance];
    return [[central manager] state] != CBCentralManagerStateUnknown
        && [[central manager] state] != CBCentralManagerStateResetting;
}

- (BOOL)isBleOn {
    LGCentralManager* central = [LGCentralManager sharedInstance];
    return [[central manager] state] == CBCentralManagerStatePoweredOn;
}

#pragma mark - Sleep Pill

- (BOOL)shouldShowPillInfo {
    return [self devices]
    && ([[self devices] hasPairedPill]
        || [[self devices] hasPairedSense]);
}

- (void)findNearestPill:(HEMDevicePillHandler)completion {
    [SENSleepPillManager scanForSleepPills:^(NSArray<SENSleepPill *> *pills, NSError *error) {
        SENSleepPill* pill = nil;
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            // first pill has the strongest signal, but we should only return a
            // pill if it meets minimum RSSI value
            pill = [pills firstObject];
            if ([pill rssi] < HEMPillDfuPillMinimumRSSI) {
                pill = nil;
            }
        }
        completion (pill, error);
    }];
}

- (BOOL)isScanningPill {
    return [SENSleepPillManager isScanning];
}

- (void)beginPillDfuFor:(SENSleepPill*)sleepPill
               progress:(HEMDeviceDfuProgressHandler)progressBlock
             completion:(HEMDeviceDfuHandler)completion {
    SENPillMetadata* pillMetadata = [[self devices] pillMetadata];
    NSString* updateUrl = [pillMetadata firmwareUpdateUrl];
    if (!updateUrl) {
        updateUrl = [HEMConfig stringForConfig:HEMConfPillFirmwareURL];
    }
    
    if (!updateUrl) {
        return completion ([self errorWithCode:HEMDeviceErrorNoPillFirmwareURL]);
    }
    
    __weak typeof(self) weakSelf = self;
    
    if (![[[self pillManager] sleepPill] isEqual:sleepPill]) {
        [self setPillManager:[[SENSleepPillManager alloc] initWithSleepPill:sleepPill]];
    }
    
    [[self pillManager] performDFUWithURL:updateUrl progress:^(CGFloat progress, SENSleepPillDfuState state) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (progressBlock) {
            progressBlock (progress, [strongSelf deviceDfuStateFromPillDfuState:state]);
        }
    } completion:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [strongSelf saveLastPillUpdate];
            [strongSelf setPillManager:nil];
        }
        
        completion (error);
    }];
}

- (HEMDeviceDfuState)deviceDfuStateFromPillDfuState:(SENSleepPillDfuState)state {
    switch (state) {
        case SENSleepPillDfuStateConnecting:
            return HEMDeviceDfuStateConnecting;
        case SENSleepPillDfuStateUpdating:
            return HEMDeviceDfuStateUpdating;
        case SENSleepPillDfuStateValidating:
            return HEMDeviceDfuStateValidating;
        case SENSleepPillDfuStateDisconnecting:
            return HEMDeviceDfuStateDisconnecting;
        case SENSleepPillDfuStateCompleted:
            return HEMDeviceDfuStateCompleted;
        default:
            return HEMDeviceDfuStateNotStarted;
    }
}

- (void)saveLastPillUpdate {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    [localPrefs setUserPreference:[NSDate date] forKey:HEMPillDfuPrefLastUpdate];
}

- (NSDate*)lastPillFirmwareUpdate {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    return [localPrefs userPreferenceForKey:HEMPillDfuPrefLastUpdate];
}

- (BOOL)shouldSuppressPillFirmwareUpdate {
    BOOL suppress = NO;
    NSDate* date = [self lastPillFirmwareUpdate];
    if (date) {
        NSInteger hoursSince = [date hoursElapsed];
        suppress = hoursSince < HEMPillDfuSuppressionReq;
        DDLogVerbose(@"hours since last update %ld", (long)hoursSince);
    }
    return suppress;
}

- (BOOL)meetsPhoneBatteryRequirementForDFU:(float)batteryLevel {
    return batteryLevel > HEMPillDfuMinPhoneBattery;
}

- (BOOL)isPillFirmwareUpdateAvailable {
    SENPillMetadata* pillMetadata = [[self devices] pillMetadata];
    return [pillMetadata firmwareUpdateUrl] != nil
        && ![self shouldSuppressPillFirmwareUpdate];
}

#pragma mark - Upgrade

- (BOOL)hasHardwareUpgradeForSense {
    SENSenseMetadata* sense = [[self devices] senseMetadata];
    return [sense hardwareVersion] == SENSenseHardwareOne;
}

- (void)issueSwapIntentFor:(SENSense*)sense completion:(HEMDeviceUpgradeHandler)completion {
    NSString* senseId = [sense deviceId];
    if (!senseId) {
        NSError* error = [self errorWithCode:HEMDeviceErrorInvalidArgument];
        [SENAnalytics trackError:error];
        return completion (error);
    }

    __weak typeof(self) weakSelf = self;
    [SENAPIDevice issueIntentToSwapWithDeviceId:senseId completion:^(SENSwapStatus* status, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSError* swapError = error;
        
        switch ([status response]) {
            case SENSwapResponseTooManyDevices:
                swapError = [strongSelf errorWithCode:HEMDeviceErrorSwapErrorMultipleSenses];
                break;
            case SENSwapResponsePairedToAnother:
                swapError = [strongSelf errorWithCode:HEMDeviceErrorSwapErrorPairedToAnother];
            default:
                break;
        }
        
        if (swapError) {
            [SENAnalytics trackError:swapError];
        }
        
        completion (swapError);
    }];
}

- (void)listenForSenseDisconnect {
    if (![self senseDisconnectObserver]) {
        __weak typeof(self) weakSelf = self;
        self.senseDisconnectObserver = [[self senseManager] observeUnexpectedDisconnect:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf resetHandler]) {
                [strongSelf resetHandler] (error);
                [strongSelf setResetHandler:nil];
            }
        }];
    }
}

- (void)removeSenseDisconnectObserver {
    if ([self senseDisconnectObserver] && [self senseManager]) {
        [[self senseManager] removeUnexpectedDisconnectObserver:[self senseDisconnectObserver]];
        [self setSenseDisconnectObserver:nil];
    }
}

- (void)hardFactoryResetSense:(NSString*)senseId completion:(HEMDeviceResetHandler)completion {
    __weak typeof(self) weakSelf = self;
    [self setResetHandler:completion];
    [self listenForSenseDisconnect];
    
    [SENSenseManager whenBleStateAvailable:^(BOOL on) {
        [SENSenseManager scanForSense:^(NSArray *senses) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            void(^done)(NSError* error) = ^(NSError* error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf removeSenseDisconnectObserver];
                [[strongSelf senseManager] disconnectFromSense];
                [strongSelf setSenseManager:nil];
                
                if (error) {
                    [SENAnalytics trackError:error];
                }
                
                if ([strongSelf resetHandler]) {
                    [strongSelf resetHandler] (error);
                    [strongSelf setResetHandler:nil];
                }
            };
            
            BOOL found = NO;
            if ([senses count] > 0) {
                for (SENSense* scannedSense in senses) {
                    if ([[scannedSense deviceId] isEqualToString:senseId]) {
                        found = YES;
                        [strongSelf setSenseManager:[[SENSenseManager alloc] initWithSense:scannedSense]];
                        [[strongSelf senseManager] setLED:SENSenseLEDStateActivity completion:^(id response, NSError *error) {
                            if (!error) {
                                [[strongSelf senseManager] resetToFactoryState:^(id response) {
                                    done(nil);
                                } failure:done];
                            } else {
                                done (error);
                            }
                        }];
                        break;
                    }
                }
            }
            
            if (!found) {
                done ([strongSelf errorWithCode:HEMDeviceErrorFactoryResetSenseNotFound]);
            }
        }];
    }];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
