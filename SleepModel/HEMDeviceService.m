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

#import "HEMDeviceService.h"
#import "HEMConfig.h"
#import "NSDate+HEMRelative.h"

NSString* const HEMDeviceServiceErrorDomain = @"is.hello.app.service.device";

static NSInteger const HEMPillDfuPillMinimumRSSI = -70;
static NSString* const HEMPillDfuBinURL = @"https://s3.amazonaws.com/hello-firmware/kodobannin/mobile/pill.hex";
static NSString* const HEMPillDfuPrefLastUpdate = @"HEMPillDfuPrefLastUpdate";
static NSUInteger const HEMPillDfuSuppressionReq = 2; // will not show dfu updates if done within the hour
static CGFloat const HEMPillDfuMinPhoneBattery = 0.2f;

@interface HEMDeviceService()

@property (nonatomic, strong) SENPairedDevices* devices;
@property (nonatomic, strong) SENSleepPillManager* pillManager;

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
            [strongSelf setDevices:devices];
        }
        completion (devices, error);
    }];
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
    
    if ([self pillManager]) {
        if (![[[self pillManager] sleepPill] isEqual:sleepPill]) {
            [self setPillManager:[[SENSleepPillManager alloc] initWithSleepPill:sleepPill]];
        }
    } else {
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

#pragma mark - Upgrade

- (void)issueSwapIntentFor:(SENSense*)sense completion:(HEMDeviceUpgradeHandler)completion {
    NSString* senseId = [sense deviceId];
    if (!senseId) {
        NSError* error = [self errorWithCode:HEMDeviceErrorInvalidArgument];
        [SENAnalytics trackError:error];
        return completion (error);
    }

    [SENAPIDevice issueIntentToSwapWithDeviceId:senseId completion:^(id data, NSError *error) {
        // TODO: handle response data to translate status to result
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (error);
    }];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
