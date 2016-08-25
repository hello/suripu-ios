//
//  HEMWifiViewController.h
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"
#import "HEMWiFiConfigurationDelegate.h"
#import "HEMSensePairDelegate.h"

@class SENWifiEndpoint;

@interface HEMWifiPasswordViewController : HEMOnboardingController

@property (nonatomic, strong) SENWifiEndpoint* endpoint;
@property (nonatomic, weak)   id<HEMWiFiConfigurationDelegate> delegate;
@property (nonatomic, weak)   id<HEMSensePairingDelegate> sensePairDelegate;
@property (nonatomic, assign, getter=isUpgrading) BOOL upgrading;

@end
