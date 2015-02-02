//
//  HEMSensePairDelegate.h
//  Sense
//
//  Created by Jimmy Lu on 1/8/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

@protocol HEMSensePairingDelegate <NSObject>

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller;
- (void)didSetupWiFiForPairedSense:(BOOL)setup from:(UIViewController*)controller;

@end
