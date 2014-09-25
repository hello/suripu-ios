//
//  HEMPillViewController.h
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SENDevice;

@interface HEMPillViewController : UIViewController

@property (nonatomic, strong) SENDevice* pill;
@property (nonatomic, strong) SENDevice* sense; // used to unpair

@end
