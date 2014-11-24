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

@interface HEMSenseSetupViewController ()

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

@property (assign, nonatomic) CGFloat buttonContainerShadowOpacity;

@end

@implementation HEMSenseSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    
    [self setupContent];
    
    [HEMOnboardingUtils applyShadowToButtonContainer:[self buttonContainer]];
    
    [self setButtonContainerShadowOpacity:[[[self buttonContainer] layer] shadowOpacity]];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBSenseSetup];
}

- (void)setupContent {
    NSString* desc = NSLocalizedString(@"sense-setup.description", nil);
    NSMutableAttributedString* attrText =
        [[NSMutableAttributedString alloc] initWithString:desc];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self contentView] addTitle:NSLocalizedString(@"sense-setup.title", nil)];
    [[self contentView] addImage:[HelloStyleKit sensePlacement]];
    [[self contentView] addDescription:attrText];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat shadowOpacity
        = [[self contentView] scrollRequired]
        ? [self buttonContainerShadowOpacity]
        : 0.0f;
    [[[self buttonContainer] layer] setShadowOpacity:shadowOpacity];
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    [HEMSupportUtil openHelpFrom:self];
}

@end
