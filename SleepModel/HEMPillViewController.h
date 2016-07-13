//
//  HEMPillViewController.h
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMPillViewController;
@class HEMDeviceService;

@protocol HEMPillControllerDelegate <NSObject>

@optional
- (void)willUnpairPillFrom:(HEMPillViewController*)viewController;
- (void)didUnpairPillFrom:(HEMPillViewController*)viewController;

@end

@interface HEMPillViewController : HEMBaseController

@property (nonatomic, weak) id<HEMPillControllerDelegate> delegate;
@property (nonatomic, strong) HEMDeviceService* deviceService;

@end
