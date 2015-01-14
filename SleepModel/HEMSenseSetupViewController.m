//
//  HEMSenseSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "UIFont+HEMStyle.h"

#import "HEMSenseSetupViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMSupportUtil.h"

@interface HEMSenseSetupViewController ()

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

@end

@implementation HEMSenseSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showHelpButton];
    [self enableBackButton:NO];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBSenseSetup];
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    [HEMSupportUtil openHelpFrom:self];
}

@end
