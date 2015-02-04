//
//  HEMSensePairDelegate.h
//  Sense
//
//  Created by Jimmy Lu on 1/8/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

@protocol HEMSensePairingDelegate <NSObject>

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller;
- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller;

@optional
- (void)willSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller;

@end
