//
//  HEMPillDescriptionViewController.m
//  Sense
//
//  Created by Jimmy Lu on 2/3/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMPillDescriptionViewController.h"
#import "HEMOnboardingService.h"
#import "HEMPillDescriptionPresenter.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMAlertViewController.h"
#import "HEMSupportUtil.h"

@interface HEMPillDescriptionViewController() <
    HEMPillDescriptionDelegate,
    HEMPresenterErrorDelegate
>

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *laterButton;

@end

@implementation HEMPillDescriptionViewController

- (void)viewDidLoad {
    [self configurePresenter]; // required to go before calling super viewDidLoad
    [super viewDidLoad];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventSleepPill];
}

- (void)configurePresenter {
    if (![self presenter]) {
        [self setPresenter:[HEMPillDescriptionPresenter new]];
    }
    
    [[self presenter] setDelegate:self];
    [[self presenter] setErrorDelegate:self];
    [[self presenter] bindWithTitleLabel:[self titleLabel]
                        descriptionLabel:[self descriptionLabel]];
    [[self presenter] bindWithContinueButton:[self continueButton]];
    [[self presenter] bindWithLaterButton:[self laterButton]];
    [[self presenter] bindWithActivityContainerView:[[self navigationController] view]];
    [[self presenter] bindWithNavigationItem:[self navigationItem]];
    
    [self addPresenter:[self presenter]];
}

#pragma mark - HEMPillDescriptionDelegate

- (void)skip:(BOOL)skip fromPresenter:(HEMPillDescriptionPresenter *)presenter {
    if (![self continueWithFlowBySkipping:skip]) {
        NSString* segueId = [HEMOnboardingStoryboard pairPillSegueIdentifier];
        [self performSegueWithIdentifier:segueId sender:self];
    }
}

- (void)showHelpPage:(NSString*)page fromPresenter:(HEMPillDescriptionPresenter*)presenter {
    [HEMSupportUtil openHelpToPage:page fromController:self];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(nullable NSString*)title
                andMessage:(NSString*)message
              withHelpPage:(nullable NSString*)helpPage
             fromPresenter:(HEMPresenter*)presenter {
    if (helpPage) {
        [self showMessageDialog:message
                          title:title
                          image:nil
                   withHelpPage:helpPage];
    } else {
        [self showMessageDialog:message title:title];
    }
}

- (void)showCustomerAlert:(HEMAlertViewController*)alert
            fromPresenter:(HEMPresenter*)presenter {
    [alert setViewToShowThrough:[self backgroundViewForAlerts]];
    [alert showFrom:self];
}


@end
