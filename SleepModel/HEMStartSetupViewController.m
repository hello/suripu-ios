//
//  HEMStartSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMStartSetupViewController.h"
#import "HEMActionButton.h"

@interface HEMStartSetupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *onePillButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *twoPillButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleHeightConstraint;

@end

@implementation HEMStartSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    CGSize constraint = CGSizeZero;
    constraint.width = CGRectGetWidth([[self subtitleLabel] bounds]);
    constraint.height = MAXFLOAT;
    CGSize textSize = [[self subtitleLabel] sizeThatFits:constraint];
    DLog(@"text height %f", textSize.height);
}

#pragma mark - Actions

- (IBAction)setupNewSense:(id)sender {
    DLog(@"new sense");
}

- (IBAction)help:(id)sender {
    DLog(@"help");
}

@end
