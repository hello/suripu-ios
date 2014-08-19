//
//  HEMBluetoothViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Delisa Mason. All rights reserved.
//

#import "HEMBluetoothViewController.h"
#import "HEMOnboardingController+Protected.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMBluetoothViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bluetoothLogo;
@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *noSenseButton;

@end

@implementation HEMBluetoothViewController

#pragma mark - Actions

- (IBAction)pair:(id)sender {
    NSLog(@"pair");
    [self pushViewController:[HEMOnboardingStoryboard instantiateWifiViewController] progress:3/9.0f];
}

- (IBAction)skip:(id)sender {
    NSLog(@"skip");
}

@end
