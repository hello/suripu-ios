//
//  HEMSenseViewController.h
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SENDevice;
@class SENSenseManager;

@interface HEMSenseViewController : UIViewController

@property (nonatomic, strong) SENDevice* senseInfo;
@property (nonatomic, strong) SENSenseManager* senseManager;

@end
