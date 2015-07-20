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
    
    // start checking for paired accounts to the previously paired Sense so
    // that future steps in the flow can use the cached data
    [[HEMOnboardingService sharedService] checkNumberOfPairedAccounts];
    [self trackAnalyticsEvent:HEMAnalyticsEventSleepPill];
}

@end
