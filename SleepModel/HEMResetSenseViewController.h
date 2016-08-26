//
//  HEMResetSenseViewController.h
//  Sense
//
//  Created by Jimmy Lu on 8/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMOnboardingController.h"

@class HEMResetSensePresenter;
@class HEMDeviceService;

@interface HEMResetSenseViewController : HEMOnboardingController

@property (nonatomic, strong) HEMResetSensePresenter* presenter;
@property (nonatomic, strong) HEMDeviceService* deviceService;
@property (nonatomic, copy) NSString* senseId;

@end
