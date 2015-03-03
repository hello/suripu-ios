//
//  HEMSenseSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSenseSetupViewController.h"
#import "HEMActionButton.h"

@interface HEMSenseSetupViewController ()

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@end

@implementation HEMSenseSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.sense-about", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropSenseSetup];
    [self enableBackButton:NO];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBSenseSetup];
}

@end
