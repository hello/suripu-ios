//
//  HEMWifiViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "HEMWifiViewController.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"

@interface HEMWifiViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wifiLogoView;
@property (weak, nonatomic) IBOutlet HEMActionButton *shareCredentialsButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareVSpaceConstraint;

@end

@implementation HEMWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -40.0f;
    [self updateConstraint:[self logoVSpaceConstraint] withDiff:diff];
    [self updateConstraint:[self shareVSpaceConstraint] withDiff:diff];
}

- (IBAction)connectWifi:(id)sender {
    NSLog(@"WARNING: this hasn't been implemented!");
}

@end
