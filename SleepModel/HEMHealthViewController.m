//
//  HEMHealthViewController.m
//  Sense
//
//  Created by Jimmy Lu on 5/26/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENServiceHealthKit.h>

#import "HEMHealthViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMHealthViewController ()

@property (nonatomic, weak) IBOutlet UIImageView* descImageView;

@end

@implementation HEMHealthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventHealth];
}

#pragma mark - Actions

- (IBAction)skip:(id)sender {
    [self next];
}

- (IBAction)enableHealthKit:(id)sender {
    SENServiceHealthKit* service = [SENServiceHealthKit sharedService];
    if (![service isSupported]) {
        [self showMessageDialog:NSLocalizedString(@"onboarding.health.enable.failure.unsupported", nil)
                          title:NSLocalizedString(@"onboarding.health.enable.failure.title", nil)];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [service requestAuthorization:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            if ([error code] != SENServiceHealthKitErrorCancelledAuthorization) {
                [SENAnalytics trackError:error];
                [strongSelf showMessageDialog:NSLocalizedString(@"onboarding.health.enable.failure.generic", @"")
                                        title:NSLocalizedString(@"onboarding.health.enable.failure.title", @"")];
            }
            return;
        }
        
        [service setEnableHealthKit:YES];
        [strongSelf next];
    }];
}

#pragma mark - Segues

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard healthKitToLocationSegueIdentifier] sender:self];
}

@end
