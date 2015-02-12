//
//  HEMSensePairingModeViewController.m
//  Sense
//
//  Created by Jimmy Lu on 1/15/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMSensePairingModeViewController.h"
#import "HEMActionButton.h"

@interface HEMSensePairingModeViewController()

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@end

@implementation HEMSensePairingModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.sense-pairing-mode", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropSensePairingMode];
    [SENAnalytics track:kHEMAnalyticsEventOnBPairingMode];
}

- (IBAction)done:(id)sender {
    // just go back to Sense Pairing
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
