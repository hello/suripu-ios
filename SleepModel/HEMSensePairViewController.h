//
//  HEMBluetoothViewController.h
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"
#import "HEMSensePairDelegate.h"

@interface HEMSensePairViewController : HEMBaseController

@property (nonatomic, weak) id<HEMSensePairingDelegate> delegate;

@end
