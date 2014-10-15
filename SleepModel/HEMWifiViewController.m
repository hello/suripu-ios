//
//  HEMWifiViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMWifiViewController.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMUserDataCache.h"
#import "HEMWifiUtils.h"
#import "HEMRoundedTextField.h"

@interface HEMWifiViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *ssidField;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *passwordField;

@end

@implementation HEMWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self ssidField] setText:[HEMWifiUtils connectedWifiSSID]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[[self ssidField] text] length] == 0) {
        [[self ssidField] becomeFirstResponder];
    } else {
        [[self passwordField] becomeFirstResponder];
    }
}

#pragma mark - Actions

- (IBAction)connectWifi:(id)sender {
    NSLog(@"WARNING: this hasn't been fully implemented!");
    // we will need to do a few things:
    // 2. pass the credentials to Morpheus and allow it to set up
    // 3. once #2 is successful, link account to morpheus and wait
    [self linkAccount];
}

- (IBAction)help:(id)sender {
    
}

- (void)linkAccount {
    NSString* accessToken = [SENAuthorizationService accessToken];
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    
    __weak typeof(self) weakSelf = self;
    [manager linkAccount:accessToken success:^(id response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf next];
        }
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSString* msg = NSLocalizedString(@"pairing.error.sense-setup-failed", nil);
            NSString* title = NSLocalizedString(@"pairing.setup.failed.title", nil);
            [strongSelf showMessageDialog:msg title:title];
        }
    }];
}

#pragma mark - Navigation

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard pillSegueIdentifier]
                              sender:nil];
}

@end
