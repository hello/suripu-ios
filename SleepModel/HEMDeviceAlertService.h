//
//  HEMDeviceAlertService.h
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

@class HEMDeviceAlertService;

typedef NS_ENUM(NSInteger, HEMDeviceAlertState) {
    HEMDeviceAlertStateUnknown = 0,
    HEMDeviceAlertStateNormal,
    HEMDeviceAlertStateSenseNotPaired,
    HEMDeviceAlertStatePillNotPaired,
    HEMDeviceAlertStatePillLowBattery,
    HEMDeviceAlertStateSenseNotSeen,
    HEMDeviceAlertStatePillNotSeen
};

typedef NS_ENUM(NSInteger, HEMDeviceChange) {
    HEMDeviceChangeNothing = (1 << 0),
    HEMDeviceChangeSensePaired = (1 << 1),
    HEMDeviceChangeSenseUnpaired = (1 << 2),
    HEMDeviceChangePillPaired = (1 << 3),
    HEMDeviceChangePillUnpaired = (1 << 4)
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMDeviceAlertStateCallback)(HEMDeviceAlertState state);
typedef void(^HEMDeviceAlertChangeCallback)(HEMDeviceChange change);

@interface HEMDeviceAlertService : SENService

- (void)checkDeviceState:(HEMDeviceAlertStateCallback)completion;
- (void)updateLastAlertShownForState:(HEMDeviceAlertState)state;
- (void)observeDeviceChanges:(HEMDeviceAlertChangeCallback)changeCallback;

@end

NS_ASSUME_NONNULL_END
