//
//  HEMDeviceService.h
//  Sense
//
//  Created by Jimmy Lu on 12/29/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

@class SENPairedDevices;
@class SENDeviceMetadata;
@class SENPillMetadata;
@class SENSleepPill;

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
    HEMDeviceErrorNoPillFirmwareURL = -10
};

typedef void(^HEMDevicePillHandler)(SENSleepPill* _Nullable sleepPill, NSError* _Nullable error);
typedef void(^HEMDeviceDfuHandler)(NSError* _Nullable error);
typedef void(^HEMDeviceDfuProgressHandler)(CGFloat progress, HEMDeviceDfuState state);
typedef void(^HEMDeviceMetadataHandler)(SENPairedDevices* _Nullable devices, NSError* _Nullable error);

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
- (void)refreshMetadata:(HEMDeviceMetadataHandler)completion;
- (BOOL)shouldWarnAboutLastSeenForDevice:(SENDeviceMetadata*)metadata;
- (BOOL)isBleOn;
- (BOOL)isBleStateAvailable;
- (BOOL)isScanningPill;
- (void)findNearestPill:(HEMDevicePillHandler)completion;
- (void)beginPillDfuFor:(SENSleepPill*)sleepPill
               progress:(HEMDeviceDfuProgressHandler)progressBlock
             completion:(HEMDeviceDfuHandler)completion;

/**
 * @return YES if we should show pill information to the users, NO otherwise
 */
- (BOOL)shouldShowPillInfo;

@end

NS_ASSUME_NONNULL_END