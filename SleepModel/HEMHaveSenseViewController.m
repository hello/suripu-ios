//
//  HEMHaveSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/3/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

#import "HEMHaveSenseViewController.h"
#import "HEMSupportUtil.h"

@interface HEMHaveSenseViewController()

@property (weak, nonatomic) IBOutlet UIButton *orderSenseButton;

@end

@implementation HEMHaveSenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureButtons];
    [SENAnalytics track:HEMAnalyticsEventOnbStart];
}

- (void)configureButtons {
    [self showBackButtonAsCancelWithSelector:@selector(cancel:)];
    [[self orderSenseButton] setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[[self orderSenseButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)orderSense:(id)sender {
    [HEMSupportUtil openOrderFormFrom:self];
    [SENAnalytics track:kHEMAnalyticsEventOnBNoSense];
}

@end
