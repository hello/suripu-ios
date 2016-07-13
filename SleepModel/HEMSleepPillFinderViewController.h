//
//  HEMSleepPillFinderViewController.h
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"
#import "HEMSleepPillDFUDelegate.h"

@class HEMDeviceService;

@interface HEMSleepPillFinderViewController : HEMBaseController

@property (nonatomic, strong) HEMDeviceService* deviceService;
@property (nonatomic, weak) id<HEMSleepPillDFUDelegate> delegate;

@end
