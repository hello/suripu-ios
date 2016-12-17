//
//  HEMSignInNavBarPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 5/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "UIBarButtonItem+HEMNav.h"

#import "HEMSignInNavBarPresenter.h"
#import "HEMOnboardingController.h"
#import "HEMStyle.h"



@implementation HEMSignInNavBarPresenter

- (void)bindWithOnboardingController:(HEMOnboardingController*)onbController {
    UINavigationItem* navItem = [onbController navigationItem];
    
    // forgot password
    UIView* rightButtonView = [[navItem rightBarButtonItem] customView];
    UIButton* rightButton = [[rightButtonView subviews] firstObject];
    [rightButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[rightButton titleLabel] setFont:[UIFont body]];
    [rightButton setTitle:NSLocalizedString(@"authorization.forgot-pass", nil)
                             forState:UIControlStateNormal];
    [rightButton addTarget:self
                    action:@selector(forgotPassword)
          forControlEvents:UIControlEventTouchUpInside];
    
    // cancel
    UIBarButtonItem* cancelItem = [UIBarButtonItem cancelItemWithTitle:nil
                                                                 image:[UIImage imageNamed:@"backIcon"]
                                                                target:self
                                                                action:@selector(dismiss)];
    
    [onbController setCancelItem:cancelItem];
    [onbController setLeftBarItem:cancelItem];
    [navItem setLeftBarButtonItem:cancelItem];
}

- (void)forgotPassword {
    [[self delegate] showForgotPasswordScreenFrom:self];
}

- (void)dismiss {
    [[self delegate] dismissControllerFrom:self];
}

@end
