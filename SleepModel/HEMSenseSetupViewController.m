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
#import "HEMScrollableView.h"

static CGFloat const HEMSenseSetupImageYPadding = 44.0f;

@interface HEMSenseSetupViewController ()

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

@end

@implementation HEMSenseSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContent];
    [self showHelpButton];
    [self enableBackButton:NO];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBSenseSetup];
}

- (void)setupContent {
    NSString* desc = NSLocalizedString(@"sense-setup.description", nil);
    NSMutableAttributedString* attrText =
        [[NSMutableAttributedString alloc] initWithString:desc];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self contentView] addTitle:NSLocalizedString(@"sense-setup.title", nil)];
    [[self contentView] addDescription:attrText];
    [[self contentView] addImage:[HelloStyleKit sensePlacement]
                     withYOffset:HEMSenseSetupImageYPadding];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat shadowOpacity = [[self contentView] scrollRequired]?1.0f:0.0f;
    [[[self buttonContainer] layer] setShadowOpacity:shadowOpacity];
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    [HEMSupportUtil openHelpFrom:self];
}

@end
