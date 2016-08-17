//
//  HEMPairPillPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPillDescriptionPresenter.h"
#import "HEMOnboardingService.h"

@implementation HEMPillDescriptionPresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {
    [titleLabel setText:NSLocalizedString(@"onboarding.pill.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"onboarding.pill.description", nil)];
}

- (void)bindWithContinueButton:(UIButton*)continueButton {
    [continueButton setTitle:[NSLocalizedString(@"actions.continue", nil) uppercaseString]
                    forState:UIControlStateNormal];
    [continueButton addTarget:self
                       action:@selector(proceed)
             forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithLaterButton:(UIButton*)laterButton {
    [laterButton setHidden:YES];
    [laterButton setUserInteractionEnabled:NO];
}

- (void)proceed {
    [[self delegate] skip:NO fromPresenter:self];
}

@end
