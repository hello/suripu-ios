//
//  HEMSystemAlertService.h
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMSystemAlertDomain;

typedef NS_ENUM(NSInteger, HEMSystemAlertState) {
    HEMSystemAlertStateUnknown = 0,
    HEMSystemAlertStateNormal,
    HEMSystemAlertStateSenseNotPaired,
    HEMSystemAlertStatePillNotPaired,
    HEMSystemAlertStatePillLowBattery,
    HEMSystemAlertStateSenseNotSeen,
    HEMSystemAlertStatePillNotSeen
};

typedef void(^HEMSystemAlertStateCallback)(HEMSystemAlertState state);

@interface HEMSystemAlertService : SENService

- (void)checkSystemState:(HEMSystemAlertStateCallback)completion;

@end

NS_ASSUME_NONNULL_END
