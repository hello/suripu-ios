//
//  HEMWifiViewController.h
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"
#import "HEMWiFiConfigurationDelegate.h"

@class SENWifiEndpoint;

@interface HEMWifiPasswordViewController : HEMBaseController

@property (nonatomic, strong) SENWifiEndpoint* endpoint;
@property (nonatomic, weak)   id<HEMWiFiConfigurationDelegate> delegate;

@end
