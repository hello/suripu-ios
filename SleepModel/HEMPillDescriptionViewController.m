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
}

#pragma mark - HEMPillDescriptionDelegate

- (void)skip:(BOOL)skip fromPresenter:(HEMPillDescriptionPresenter *)presenter {
    if (skip) {
        [self skipFlow]; // we don't know how to handle it, without the flow
    } else if (![self continueWithFlow]) {
        NSString* segueId = [HEMOnboardingStoryboard pairSegueIdentifier];
        [self performSegueWithIdentifier:segueId sender:self];
    }
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(nullable NSString*)title
                andMessage:(NSString*)message
              withHelpPage:(nullable NSString*)helpPage
             fromPresenter:(HEMPresenter*)presenter {
    [self showMessageDialog:message
                      title:title
                      image:nil
               withHelpPage:helpPage];
}

- (void)showCustomerAlert:(HEMAlertViewController*)alert
            fromPresenter:(HEMPresenter*)presenter {
    [alert setViewToShowThrough:[self backgroundViewForAlerts]];
    [alert showFrom:self];
}


@end
