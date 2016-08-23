//
//  HEMPillPairViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMPillPairViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSettingsTableViewController.h"
#import "HEMSupportUtil.h"
#import "HEMAlertViewController.h"
#import "HEMActivityCoverView.h"
#import "HEMEmbeddedVideoView.h"
#import "HEMPairPiillPresenter.h"

@interface HEMPillPairViewController() <HEMPresenterErrorDelegate, HEMPairPillPresenterDelegate>

@property (weak, nonatomic) IBOutlet HEMActivityCoverView *overlayActivityView;
@property (weak, nonatomic) IBOutlet HEMActionButton *retryButton;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retryButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet HEMEmbeddedVideoView *videoView;

@end

@implementation HEMPillPairViewController

- (void)viewDidLoad {
    [self configurePresenter];
    
    [super viewDidLoad];
    
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventPairPill];
}

- (void)configurePresenter {
    if (![self presenter]) {
        HEMOnboardingService* onbService = [HEMOnboardingService sharedService];
        [self setPresenter:[[HEMPairPiillPresenter alloc] initWithOnboardingService:onbService]];
    }
    
    [[self presenter] bindWithTitleLabel:[self titleLabel]
                        descriptionLabel:[self descriptionLabel]];
    [[self presenter] bindWithActivityView:[self overlayActivityView]];
    [[self presenter] bindWithEmbeddedVideoView:[self videoView]];
    [[self presenter] bindWithSkipButton:[self skipButton]];
    [[self presenter] bindWithContinueButton:[self retryButton]
                         withWidthConstraint:[self retryButtonWidthConstraint]];
    [[self presenter] bindWithNavigationItem:[self navigationItem]];
    [[self presenter] bindWithStatusLabel:[self activityLabel]];
    [[self presenter] bindWithContentContainerView:[[self navigationController] view]];
    [[self presenter] setErrorDelegate:self];
    [[self presenter] setDelegate:self];
    
    [self addPresenter:[self presenter]];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    if (helpPage) {
        [self showMessageDialog:message
                          title:title
                          image:nil
                   withHelpPage:helpPage];
    } else {
        [self showMessageDialog:message title:title];
    }
}

- (void)showCustomerAlert:(HEMAlertViewController *)alert fromPresenter:(HEMPresenter *)presenter {
    [alert setViewToShowThrough:[self backgroundViewForAlerts]];
    [alert showFrom:self];
}

#pragma mark - HEMPairPillPresenterDelegate

- (void)completePairing:(BOOL)skipped fromPresenter:(HEMPairPiillPresenter *)presenter {
    if (![self continueWithFlowBySkipping:skipped]) {
        if ([self delegate] == nil) {
            NSString* segueId = [HEMOnboardingStoryboard doneSegueIdentifier];
            [self performSegueWithIdentifier:segueId sender:self];
        } else {
            [[self delegate] didPairWithPillFrom:self];
        }
    }
}

- (void)showHelpPage:(NSString *)helpPage fromPresenter:(HEMPairPiillPresenter *)presenter {
    [HEMSupportUtil openHelpToPage:helpPage fromController:self];
}

@end
