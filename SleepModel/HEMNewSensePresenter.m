//
//  HEMNewSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMNewSensePresenter.h"

@implementation HEMNewSensePresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {}

- (void)bindWithNextButton:(UIButton*)nextButton {}

- (void)bindWithNeedButton:(UIButton*)needButton {
    Class aClass = [HEMOnboardingController class];
    UIColor* color = [SenseStyle colorWithAClass:aClass property:ThemePropertySecondaryButtonTextColor];
    UIFont* font = [SenseStyle fontWithAClass:aClass property:ThemePropertySecondaryButtonTextFont];
    [needButton setTitleColor:color forState:UIControlStateNormal];
    [[needButton titleLabel] setFont:font];
}

- (void)bindWithIllustrationView:(UIImageView*)illustrationView {
    [illustrationView setImage:[UIImage imageNamed:@"sense"]];
}

@end
