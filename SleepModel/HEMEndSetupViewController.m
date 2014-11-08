//
//  HEMEndSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>

#import "HEMUserDataCache.h"
#import "HEMEndSetupViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMActionButton.h"

@interface HEMEndSetupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet HEMActionButton *skipButton;

@end

@implementation HEMEndSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBEnd];
}

#pragma mark - Actions

- (IBAction)skip:(id)sender {
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[HEMSettingsTableViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Clean up

- (void)dealloc {
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    [manager disconnectFromSense];
    [[HEMUserDataCache sharedUserDataCache] setSenseManager:nil];
}

@end
