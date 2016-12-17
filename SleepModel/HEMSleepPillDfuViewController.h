//
//  HEMSleepPillDfuViewController.h
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBaseController.h"
#import "HEMSleepPillDFUDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class HEMDeviceService;
@class SENSleepPill;

@interface HEMSleepPillDfuViewController : HEMBaseController

@property (nonatomic, strong, nullable) HEMDeviceService* deviceService;
@property (nonatomic, strong, nullable) SENSleepPill* sleepPillToDfu;
@property (nonatomic, weak) id<HEMSleepPillDFUDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
