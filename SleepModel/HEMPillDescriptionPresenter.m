//
//  HEMPairPillPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMPillDescriptionPresenter.h"
#import "HEMOnboardingService.h"

@interface HEMPillDescriptionPresenter()

@property (nonatomic, weak) UIView* activityContainerView;

@end

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
    Class aClass = [HEMOnboardingController class];
    UIColor* color = [SenseStyle colorWithAClass:aClass property:ThemePropertySecondaryButtonTextColor];
    UIFont* font = [SenseStyle fontWithAClass:aClass property:ThemePropertySecondaryButtonTextFont];
    [[laterButton titleLabel] setFont:font];
    [laterButton setTitleColor:color forState:UIControlStateNormal];
    [laterButton setHidden:YES];
    [laterButton setUserInteractionEnabled:NO];
}

- (void)bindWithActivityContainerView:(UIView*)containerView {
    [self setActivityContainerView:containerView];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem { }

- (void)proceed {
    [[self delegate] skip:NO fromPresenter:self];
}

@end
