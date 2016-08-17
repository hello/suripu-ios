//
//  HEMUpgradePillDescriptionPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMUpgradePillDescriptionPresenter.h"
#import "HEMAlertViewController.h"

@implementation HEMUpgradePillDescriptionPresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {
    [titleLabel setText:NSLocalizedString(@"upgrade.pill.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"upgrade.pill.description", nil)];
}

- (void)bindWithContinueButton:(UIButton*)continueButton {
    [super bindWithContinueButton:continueButton];
    [continueButton setTitle:[NSLocalizedString(@"upgrade.actions.pair-pill", nil) uppercaseString]
                    forState:UIControlStateNormal];
}

- (void)bindWithLaterButton:(UIButton*)laterButton {
    [super bindWithLaterButton:laterButton];
    [laterButton setHidden:NO];
    [laterButton setUserInteractionEnabled:YES];
    [laterButton addTarget:self
                    action:@selector(skipPillPairing)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void)skipPillPairing {
    NSString* title = NSLocalizedString(@"upgrade.pill.skip-new-alert.title", nil);
    NSString* message = NSLocalizedString(@"upgrade.pill.skip-new-alert.message", nil);
    __weak typeof(self) weakSelf = self;
    HEMAlertViewController *dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"upgrade.actions.pair-pill", nil)
                           style:HEMAlertViewButtonStyleRoundRect
                          action:^{
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               [[strongSelf delegate] skip:NO fromPresenter:nil];
                          }];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"upgrade.actions.skip-new", nil)
                           style:HEMAlertViewButtonStyleBlueText
                          action:^{
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              [[strongSelf delegate] skip:YES fromPresenter:nil];
                          }];
    [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
    
}

@end
