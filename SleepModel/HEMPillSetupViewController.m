//
//  HEMPillIntroViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMPillSetupViewController.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingUtils.h"

@interface HEMPillSetupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraint;


@end

@implementation HEMPillSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [self setupDescription];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBPillPlacement];
}

- (void)setupDescription {
    NSString* desc = NSLocalizedString(@"onboarding.pill-setup.description", nil);
    NSMutableAttributedString* attributedDesc = [[NSMutableAttributedString alloc] initWithString:desc];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attributedDesc];
    [[self descLabel] setAttributedText:attributedDesc];
}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self imageHeightConstraint] withDiff:-60.0f];
    [self updateConstraint:[self imageTopConstraint] withDiff:-10.0f];
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    [HEMSupportUtil openHelpFrom:self];
}

@end
