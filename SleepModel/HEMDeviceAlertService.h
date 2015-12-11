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

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMDeviceAlertStateCallback)(HEMDeviceAlertState state);

@interface HEMDeviceAlertService : SENService

- (void)checkDeviceState:(HEMDeviceAlertStateCallback)completion;
- (void)updateLastAlertShownForState:(HEMDeviceAlertState)state;

@end

NS_ASSUME_NONNULL_END
