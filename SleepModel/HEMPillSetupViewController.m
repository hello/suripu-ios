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
@property (assign, nonatomic, getter=isWaitingForLED) BOOL waitingForLED;

@end

@implementation HEMPillSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self enableBackButton:NO];
    [self showHelpButton];
    [self turnOnLEDBriefly];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBPillPlacement];
}

- (void)turnOnLEDBriefly {
    [self setWaitingForLED:YES];
    __weak typeof(self) weakSelf = self;
    [[self manager] setLED:SENSenseLEDStatePair completion:^(__unused id response, __unused  NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if ([[strongSelf navigationController] topViewController] != strongSelf) {
            [[strongSelf manager] setLED:SENSenseLEDStateOff completion:nil];
        }
        [strongSelf setWaitingForLED:NO];
    }];
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    if (![self isWaitingForLED]) {
        [[self manager] setLED:SENSenseLEDStateOff completion:nil];
    }
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard pillSetupToColorsSegueIdentifier]
                              sender:self];
}

@end
