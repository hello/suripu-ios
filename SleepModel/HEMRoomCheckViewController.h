//
//  HEMRoomCheckViewController.h
//  Sense
//
//  Created by Jimmy Lu on 12/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class SENSensor;

@interface HEMRoomCheckViewController : HEMOnboardingController

@property (nonatomic, strong) NSArray<SENSensor*>* sensors;

@end
