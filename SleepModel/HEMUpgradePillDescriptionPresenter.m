//
//  HEMUpgradePillDescriptionPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMUpgradePillDescriptionPresenter.h"

@implementation HEMUpgradePillDescriptionPresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {
    [titleLabel setText:NSLocalizedString(@"upgrade.pill.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"upgrade.pill.description", nil)];
}

- (void)bindWithContinueButton:(UIButton*)continueButton {
    [continueButton setTitle:NSLocalizedString(@"upgrade.actions.pair-pill", nil)
                    forState:UIControlStateNormal];
}

- (void)bindWithLaterButton:(UIButton*)laterButton {
    [laterButton setHidden:NO];
    [laterButton setUserInteractionEnabled:YES];
}

@end
