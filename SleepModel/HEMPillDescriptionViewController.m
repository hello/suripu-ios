//
//  HEMPillDescriptionViewController.m
//  Sense
//
//  Created by Jimmy Lu on 2/3/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMPillDescriptionViewController.h"
#import "HEMOnboardingService.h"

@implementation HEMPillDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventSleepPill];
}

@end
