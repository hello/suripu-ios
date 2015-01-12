//
//  HEMSecondPillSetupViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMSecondPillCheckViewController.h"
#import "HEMOnboardingController.h"

@interface HEMSecondPillSetupViewController : HEMOnboardingController

@property (nonatomic, weak) id<HEMSecondPillCheckDelegate> delegate;

@end
