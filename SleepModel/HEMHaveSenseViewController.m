//
//  HEMHaveSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/3/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMHaveSenseViewController.h"

@implementation HEMHaveSenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SENAnalytics track:HEMAnalyticsEventOnbStart];
}

@end
