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
#import "HelloStyleKit.h"

@interface HEMPillSetupViewController ()

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (assign, nonatomic, getter=isWaitingForLED) BOOL waitingForLED;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottomConstraint;

@end

@implementation HEMPillSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureAppearance];
    [self configureButtons];
    [self trackAnalyticsEvent:HEMAnalyticsEventPillPlacement];
}

- (void)configureButtons {
    [self enableBackButton:NO];
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.pill-setup", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropPillPlacement];
}

- (void)configureAppearance {
    NSShadow* shadow = [HelloStyleKit buttonContainerShadow];
    CALayer* containerLayer = [[self buttonContainer] layer];
    [containerLayer setShadowColor:[[shadow shadowColor] CGColor]];
    [containerLayer setShadowOffset:[shadow shadowOffset]];
    [containerLayer setShadowRadius:[shadow shadowBlurRadius]];
    [containerLayer setShadowOpacity:1.0f];
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    
    CGFloat constant = [[self imageBottomConstraint] constant] - 100.0f;
    [[self imageBottomConstraint] setConstant:constant];
}

- (void)adjustConstraintsForIphone5 {
    [super adjustConstraintsForIphone5];
    
    CGFloat constant = [[self imageBottomConstraint] constant] - 40.0f;
    [[self imageBottomConstraint] setConstant:constant];
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    [[self manager] setLED:SENSenseLEDStateOff completion:nil];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard pillSetupToColorsSegueIdentifier]
                              sender:self];
}

@end
