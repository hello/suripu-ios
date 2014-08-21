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

@interface HEMBluetoothViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bluetoothLogo;
@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *noSenseButton;

@end

@implementation HEMBluetoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] popToViewController:self animated:NO];
}

#pragma mark - Actions

- (IBAction)pair:(id)sender {
    // TODO (jimmy): actually do the pairing!
    [self performSegueWithIdentifier:@"wifi" sender:self];
}

- (IBAction)skip:(id)sender {
    NSLog(@"skip");
}

@end
