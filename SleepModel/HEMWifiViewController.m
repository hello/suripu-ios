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

@interface HEMWifiViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wifiLogoView;
@property (weak, nonatomic) IBOutlet HEMActionButton *shareCredentialsButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareButtonWidthConstraint;

@property (strong, nonatomic) id disconnectObserverId;

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

- (void)listenForDisconnects {
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    if ([self disconnectObserverId] == nil) {
        __weak typeof(self) weakSelf = self;
        self.disconnectObserverId =
        [manager observeUnexpectedDisconnect:^(NSError *error) {
            __block typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && [[strongSelf shareCredentialsButton] isShowingActivity]) {
                [[strongSelf shareCredentialsButton] stopActivity];
                [strongSelf showMessageDialog:NSLocalizedString(@"pairing.error.unexpected-disconnect", nil)
                                        title:NSLocalizedString(@"pairing.setup.failed.title", nil)];
            }
        }];
    }
}

#pragma mark - Actions

- (IBAction)connectWifi:(id)sender {
    NSLog(@"WARNING: this hasn't been fully implemented!");
    // we will need to do a few things:
    // 1. gather wifi credentials (wifi name, SSID, and password)
    // 2. pass the credentials to Morpheus and allow it to set up
    // 3. once #2 is successful, link account to morpheus and wait
    [[self shareCredentialsButton] showActivityWithWidthConstraint:[self shareButtonWidthConstraint]];
    [self linkAccount];
}

- (void)linkAccount {
    NSString* accessToken = [SENAuthorizationService accessToken];
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    
    __weak typeof(self) weakSelf = self;
    [manager linkAccount:accessToken success:^(id response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf shareCredentialsButton] stopActivity];
            [strongSelf next];
        }
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf shareCredentialsButton] stopActivity];
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
