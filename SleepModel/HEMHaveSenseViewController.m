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
    [self showBackButtonAsCancelWithSelector:@selector(cancel:)];
    [SENAnalytics track:HEMAnalyticsEventOnbStart];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
