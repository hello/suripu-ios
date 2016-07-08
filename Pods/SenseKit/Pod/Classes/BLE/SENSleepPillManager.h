//
//  SENSleepPillManager.h
//  Pods
//
//  Created by Jimmy Lu on 6/29/16.
//
//

#import <Foundation/Foundation.h>
#import "SENPeripheralManager.h"

@class SENSleepPill;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SENSleepPillErrorCode) {
    SENSleepPillErrorCodeNotSupported = -1,
    SENSleepPillErrorCodeCentralNotReady = -2,
    SENSleepPillErrorCodePillNotfound = -3,
    SENSleepPillErrorCodeConnectionFailed = -4,
    SENSleepPillErrorCodeDfuAborted = -5,
    SENSleepPillErrorCodeDfuError = -6,
    SENSleepPillErrorCodeDfuInProgress = -7,
    SENSleepPillErrorCodeDfuEnableFailed = -8,
    SENSleepPillErrorCodeDfuMissingCharacteristic = -9,
    SENSleepPillErrorCodeUnexpectedDisconnect = -10,
    SENSleepPillErrorCodeRediscoveryFailed = -11
};

typedef NS_ENUM(NSUInteger, SENSleepPillDfuState) {
    SENSleepPillDfuStateNotStarted = 1,
    SENSleepPillDfuStateConnecting,
    SENSleepPillDfuStateUpdating,
    SENSleepPillDfuStateValidating,
    SENSleepPillDfuStateDisconnecting,
    SENSleepPillDfuStateCompleted
};

typedef void(^SENSleepPillResponseHandler)(NSError* _Nullable error);

extern NSString* const HEMSleepPillManagerErrorDomain;

typedef void(^SENSleepPillManagerScanBlock)(NSArray<SENSleepPill*>* _Nullable pills, NSError* _Nullable error);
typedef void(^SENSleepPillManagerDFUBlock)(NSError* _Nullable error);
typedef void(^SENSleepPillManagerProgressBlock)(CGFloat progress, SENSleepPillDfuState state);

@interface SENSleepPillManager : SENPeripheralManager

@property (nonatomic, strong, readonly) SENSleepPill* sleepPill;

/**
 * @discussion
 * Scan for nearby Sleep Pills
 *
 * @param completion: block to call with the any nearby Sleep Pills found
 */
+ (void)scanForSleepPills:(SENSleepPillManagerScanBlock)completion;

/**
 * @discussion
 * Initialize a Sleep Pill Manager for the specified Sleep Pill.  If a sleep pill
 * is not provided, an instance is not returned
 *
 * @param sleepPill - Sleep Pill to initialize the manager for
 */
- (nullable instancetype)initWithSleepPill:(SENSleepPill*)sleepPill;

/**
 * @discussion
 * Connect to the managed Sleep Pill
 *
 * @param completion: the block to call after the connection either succeeds or fails
 */
- (void)connect:(SENSleepPillResponseHandler)completion;

/**
 * @discussion
 * Disconnect from the managed Sleep Pill
 *
 * @param completion: the block to call after the disconnect either succeeds or fails
 */
- (void)disconnect:(SENSleepPillResponseHandler)completion;

/**
 * @discussion
 * Perform a DFU (device firmware update) with the url to the specified firmware binary.
 * If the Sleep Pill is not in DFU mode, it will automatically enable it.
 *
 * @param url: the url to the specified firmware binary
 * @param progress: the block to call, if provided, whenever an update is available for the DFU
 * @param completion: the block to call after the disconnect either succeeds or fails
 */
- (void)performDFUWithURL:(NSString*)url
                 progress:(nullable SENSleepPillManagerProgressBlock)progress
               completion:(SENSleepPillManagerDFUBlock)completion;

@end

NS_ASSUME_NONNULL_END