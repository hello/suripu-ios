//
//  HEMPillIntroViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENServiceDevice.h>

#import "UIFont+HEMStyle.h"

#import "HEMPillSetupViewController.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingUtils.h"
#import "HEMOnboardingCache.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMPillSetupViewController ()

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;


@end

@implementation HEMPillSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self enableBackButton:NO];
    [self showHelpButton];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBPillPlacement];
}

- (SENSenseManager*)manager {
    SENSenseManager* manager = [[SENServiceDevice sharedService] senseManager];
    return manager ? manager : [[HEMOnboardingCache sharedCache] senseManager];
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    [[self manager] setLED:SENSenseLEDStateOff completion:nil];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard pillSetupToColorsSegueIdentifier]
                              sender:self];
}

@end
