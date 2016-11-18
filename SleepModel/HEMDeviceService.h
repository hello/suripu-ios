//
//  HEMDeviceService.h
//  Sense
//
//  Created by Jimmy Lu on 12/29/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENSleepPill.h>

@class SENPairedDevices;
@class SENDeviceMetadata;
@class SENPillMetadata;
@class SENSense;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMDeviceServiceErrorDomain;

typedef NS_ENUM(NSInteger, HEMDeviceDfuState) {
    HEMDeviceDfuStateNotStarted = 1,
    HEMDeviceDfuStateConnecting,
    HEMDeviceDfuStateUpdating,
    HEMDeviceDfuStateValidating,
    HEMDeviceDfuStateDisconnecting,
    HEMDeviceDfuStateCompleted
};

/**
 * @discussion
 * This is a direct mapping to SENServiceDeviceErrors.  Once SENServiceDevice
 * can be removed, we can probably start to deprecate some of these errors
 */
typedef NS_ENUM(NSInteger, HEMDeviceError) {
    HEMDeviceErrorSenseUnavailable = -1,
    HEMDeviceErrorBLEUnavailable = -2,
    HEMDeviceErrorInProgress = -3,
    HEMDeviceErrorSenseNotPaired = -4,
    HEMDeviceErrorPillNotPaired = -5,
    HEMDeviceErrorUnpairPillFromSense = -6,
    HEMDeviceErrorUnlinkPillFromAccount = -7,
    HEMDeviceErrorUnlinkSenseFromAccount = -8,
    HEMDeviceErrorSenseNotMatching = -9,
    HEMDeviceErrorNoPillFirmwareURL = -10,
    HEMDeviceErrorInvalidArgument = -11,
    HEMDeviceErrorSwapErrorMultipleSenses = -12,
    HEMDeviceErrorSwapErrorPairedToAnother = -13,
    HEMDeviceErrorFactoryResetSenseNotFound = -14
};

typedef void(^HEMDevicePillHandler)(SENSleepPill* _Nullable sleepPill, NSError* _Nullable error);
typedef void(^HEMDeviceDfuHandler)(NSError* _Nullable error);
typedef void(^HEMDeviceDfuProgressHandler)(CGFloat progress, HEMDeviceDfuState state);
typedef void(^HEMDeviceMetadataHandler)(SENPairedDevices* _Nullable devices, NSError* _Nullable error);
typedef void(^HEMDeviceUpgradeHandler)(NSError* _Nullable error);
typedef void(^HEMDeviceResetHandler)(NSError* _Nullable error);

/**
 * @discussion
 *
 * TODO: deprecate SENServiceDevice
 * This is intended to eventually replace SENServiceDevice.  Until Sense and Pill
 * settings are refactored to use this service, we will use this to act as a
 * fascade to SENServiceDevice so that the transition is easier.  Once references
 * to SENServiceDevice has been completely remove, we should move all logic over
 * to this class and remove SENServiceDevice completley.
 */
@interface HEMDeviceService : SENService

@property (nonatomic, strong, readonly, nullable) SENPairedDevices* devices;

- (void)clearDevicesCache;
- (void)refreshMetadata:(nullable HEMDeviceMetadataHandler)completion;
- (BOOL)shouldWarnAboutLastSeenForDevice:(SENDeviceMetadata*)metadata;
- (BOOL)isBleOn;
- (void)stopScanningForSense;
- (BOOL)isBleStateAvailable;
- (BOOL)isScanningPill;
- (void)findNearestPillWithVersion:(SENSleepPillAdvertisedVersion)version
                        completion:(HEMDevicePillHandler)completion;
- (void)findNearestPill:(HEMDevicePillHandler)completion;
- (void)beginPillDfuFor:(SENSleepPill*)sleepPill
               progress:(HEMDeviceDfuProgressHandler)progressBlock
             completion:(HEMDeviceDfuHandler)completion;
- (BOOL)shouldSuppressPillFirmwareUpdate;
- (BOOL)meetsPhoneBatteryRequirementForDFU:(float)batteryLevel;
- (void)issueSwapIntentFor:(SENSense*)sense completion:(HEMDeviceUpgradeHandler)completion;
- (void)hardFactoryResetSense:(NSString*)senseId completion:(HEMDeviceResetHandler)completion;
- (BOOL)hasHardwareUpgradeForSense;
- (BOOL)isPillFirmwareUpdateAvailable;
- (SENSenseHardware)savedHardwareVersion;

/**
 * @return YES if we should show pill information to the users, NO otherwise
 */
- (BOOL)shouldShowPillInfo;

@end

NS_ASSUME_NONNULL_END