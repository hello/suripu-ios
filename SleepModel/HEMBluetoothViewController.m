//
//  HEMBluetoothViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "HEMBluetoothViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"

@interface HEMBluetoothViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bluetoothLogo;
@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *noSenseButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readyVSpaceConstraint;

@property (assign, nonatomic) BOOL adjustedConstraints;

@end

@implementation HEMBluetoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] popToViewController:self animated:NO];
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -40.0f;
    [self updateConstraint:[self logoVSpaceConstraint] withDiff:diff];
    [self updateConstraint:[self readyVSpaceConstraint] withDiff:diff];
}

#pragma mark - Actions

- (IBAction)pair:(id)sender {
    // TODO (jimmy): actually do the pairing!
    [self performSegueWithIdentifier:@"wifi" sender:self];
}

@end
