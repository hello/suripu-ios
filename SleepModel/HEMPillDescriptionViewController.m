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

@interface HEMPillDescriptionViewController()

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
    
    [[self presenter] bindWithTitleLabel:[self titleLabel]
                        descriptionLabel:[self descriptionLabel]];
    [[self presenter] bindWithContinueButton:[self continueButton]];
    [[self presenter] bindWithLaterButton:[self laterButton]];
}

- (IBAction)proceed:(id)sender {
    if (![self continueWithFlow]) {
        NSString* segueId = [HEMOnboardingStoryboard pairSegueIdentifier];
        [self performSegueWithIdentifier:segueId sender:self];
    }
}

- (IBAction)later:(id)sender {
    [self skipFlow]; // we don't know how to handle it, without the flow
}

@end
