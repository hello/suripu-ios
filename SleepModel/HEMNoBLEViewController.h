//
//  HEMNoBLEViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"
#import "HEMOnboardingFlow.h"

@class HEMNoBLEViewController;

@protocol HEMNoBLEDelegate <NSObject>

- (void)bleDetectedFrom:(HEMNoBLEViewController*)controller;

@end

@interface HEMNoBLEViewController : HEMOnboardingController

@property (nonatomic, weak) id<HEMNoBLEDelegate> delegate;
@property (nonatomic, weak) id<HEMOnboardingFlow> flow;

@end
