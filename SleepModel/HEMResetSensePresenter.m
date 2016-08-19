//
//  HEMResetSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UIBarButtonItem+HEMNav.h"

#import "HEMResetSensePresenter.h"
#import "HEMActivityCoverView.h"
#import "HEMStyle.h"

@interface HEMResetSensePresenter()

@property (nonatomic, weak) UIView* activityContainerView;

@end

@implementation HEMResetSensePresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel {
    [titleLabel setText:NSLocalizedString(@"upgrade.reset.sense.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"upgrade.reset.sense.description", nil)];
}

- (void)bindWithLaterButton:(UIButton*)laterButton {
    [laterButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[laterButton titleLabel] setFont:[UIFont button]];
    [laterButton addTarget:self
                    action:@selector(later)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithResetButton:(UIButton*)resetButton {
    [resetButton addTarget:self
                    action:@selector(reset)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithActivityContainerView:(UIView*)containerView {
    [self setActivityContainerView:containerView];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    UIBarButtonItem* helpButton = [UIBarButtonItem helpButtonWithTarget:self action:@selector(help)];
    [navItem setRightBarButtonItem:helpButton];
}

#pragma mark - Actions

- (void)reset {
    NSString* resettingText = NSLocalizedString(@"upgrade.reset.status", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    
    __weak typeof(self) weakSelf = self;
    [activityView showInView:[self activityContainerView] withText:resettingText activity:YES completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSString* doneText = NSLocalizedString(@"upgrade.reset.done", nil);
        [activityView dismissWithResultText:doneText showSuccessMark:YES remove:YES completion:nil];
        
        [[strongSelf delegate] didFinishWithReset:NO fromPresenter:strongSelf];
    }];
}

- (void)later {
    [[self delegate] didFinishWithReset:YES fromPresenter:self];
}

- (void)help {
    NSString* step = kHEMAnalyticsEventPropResetSense;
    NSDictionary* properties = @{kHEMAnalyticsEventPropStep : step};
    [SENAnalytics track:kHEMAnalyticsEventOnBHelp properties:properties];
}

@end
