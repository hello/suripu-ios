//
//  HEMUpgradePairPillPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMUpgradePairPillPresenter.h"

@implementation HEMUpgradePairPillPresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel {
    [super bindWithTitleLabel:titleLabel descriptionLabel:descriptionLabel];
    [titleLabel setText:NSLocalizedString(@"upgrade.pair-pill.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"upgrade.pair-pill.description", nil)];
}

- (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)props {
    NSString* prefixedEvent = [SENAnalytics addPrefixIfNeeded:HEMAnalyticsEventUpgradePrefix
                                                      toEvent:event];
    [SENAnalytics track:prefixedEvent properties:nil];
}

@end
