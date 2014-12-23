//
//  HEMSecondPillSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "UIFont+HEMStyle.h"

#import "HEMSecondPillSetupViewController.h"
#import "HEMOnboardingUtils.h"
#import "HEMActionButton.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSupportUtil.h"
#import "HEMScrollableView.h"

@interface HEMSecondPillSetupViewController ()

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonWidthConstraint;

@end

@implementation HEMSecondPillSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContent];
    
    [HEMOnboardingUtils applyShadowToButtonContainer:[self buttonContainer]];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBPairingOff];
}

- (void)setupContent {
    NSString* descFormat = NSLocalizedString(@"second-pill.description.format", nil);
    NSString* senseSettings = NSLocalizedString(@"second-pill.description.sense-settings", nil);
    NSString* intoPairing = NSLocalizedString(@"second-pill.description.put-into-pairing", nil);
    NSString* blue = NSLocalizedString(@"onboarding.blue", nil);
    
    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:senseSettings],
        [HEMOnboardingUtils boldAttributedText:intoPairing],
        [HEMOnboardingUtils boldAttributedText:blue
                                     withColor:[UIColor blueColor]]
    ];
    
    NSMutableAttributedString* attrDesc
        = [[NSMutableAttributedString alloc] initWithFormat:descFormat args:args];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrDesc];
    
    [[self contentView] addTitle:NSLocalizedString(@"second-pill.title", nil)];
    [[self contentView] addDescription:attrDesc];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat shadowOpacity = [[self contentView] scrollRequired]?1.0f:0.0f;
    [[[self buttonContainer] layer] setShadowOpacity:shadowOpacity];
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    [[self delegate] checkController:self isSettingUpNewSense:NO];
}

- (IBAction)help:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    [HEMSupportUtil openHelpFrom:self];
}

@end
