//
//  HEMSecondPillSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMSecondPillSetupViewController.h"
#import "HEMOnboardingUtils.h"
#import "HEMActionButton.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSupportUtil.h"
#import "HEMScrollableView.h"

@interface HEMSecondPillSetupViewController ()

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@end

@implementation HEMSecondPillSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showHelpButton];
    [SENAnalytics track:kHEMAnalyticsEventOnBPairingOff];
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    [[self delegate] checkController:self isSettingUpNewSense:NO];
}

- (IBAction)help:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    [HEMSupportUtil openHelpFrom:self];
}

@end
