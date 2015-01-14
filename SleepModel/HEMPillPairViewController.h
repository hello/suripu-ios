//
//  HEMPillPairViewController.h
//  Sense
//
//  Created by Jimmy Lu on 9/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMPillPairViewController;

@protocol HEMPillPairDelegate <NSObject>

- (void)didPairWithPillFrom:(HEMPillPairViewController*)controller;
- (void)didCancelPairing:(HEMPillPairViewController*)controller;

@end

@interface HEMPillPairViewController : HEMOnboardingController

@property (nonatomic, weak) id<HEMPillPairDelegate> delegate;

@end
