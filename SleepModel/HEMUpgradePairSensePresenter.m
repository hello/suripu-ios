//
//  HEMUpgradePairSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMUpgradePairSensePresenter.h"

@implementation HEMUpgradePairSensePresenter

#pragma mark - Actions

- (void)bindWithTitleLabel:(UILabel *)titleLabel
          descriptionLabel:(UILabel *)descriptionLabel
  descriptionTopConstraint:(NSLayoutConstraint *)topConstraint {
    [super bindWithTitleLabel:titleLabel
             descriptionLabel:descriptionLabel
     descriptionTopConstraint:topConstraint];
    [titleLabel setText:NSLocalizedString(@"upgrade.pair-sense.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"upgrade.pair-sense.desc", nil)];
}

- (void)help {
    [super help];
    NSString* step = kHEMAnalyticsEventPropSensePairing;
    NSDictionary* properties = @{kHEMAnalyticsEventPropStep : step};
    [SENAnalytics track:kHEMAnalyticsEventHelp properties:properties];
}

@end
