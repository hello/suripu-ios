//
//  HEMBluetoothViewController.h
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"
#import "HEMSensePairDelegate.h"

@class HEMPairSensePresenter;

@interface HEMSensePairViewController : HEMOnboardingController

@property (nonatomic, weak) id<HEMSensePairingDelegate> delegate;
@property (nonatomic, strong) HEMPairSensePresenter* presenter;
@property (nonatomic, assign, readonly, getter=isSenseConnectedToWiFi) BOOL senseConnectedToWiFi;

@end
