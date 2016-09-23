//
//  HEMUpgradePairSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseMetadata.h>

#import "UIBarButtonItem+HEMNav.h"

#import "HEMUpgradePairSensePresenter.h"
#import "HEMOnboardingService.h"
#import "HEMDeviceService.h"

@implementation HEMUpgradePairSensePresenter

- (instancetype)initWithOnboardingService:(HEMOnboardingService *)onbService
                            deviceService:(HEMDeviceService*)deviceService {
    self = [super initWithOnboardingService:onbService deviceService:deviceService];
    if (self) {
        if ([[deviceService devices] hasPairedSense]) {
            NSString* deviceId = [[[deviceService devices] senseMetadata] uniqueId];
            if (deviceId) {
                [self setDeviceIdsToExclude:[NSSet setWithObject:deviceId]];
            }
        }
        [self setUpgrade:YES];
    }
    return self;
}

- (void)trackEvent:(NSString *)event properties:(NSDictionary *)props {
    NSString* prefixedEvent = [SENAnalytics addPrefixIfNeeded:HEMAnalyticsEventUpgradePrefix
                                                      toEvent:event];
    [SENAnalytics track:prefixedEvent properties:nil];
}

#pragma mark - Actions

- (void)bindWithTitleLabel:(UILabel *)titleLabel
          descriptionLabel:(UILabel *)descriptionLabel
  descriptionTopConstraint:(NSLayoutConstraint *)topConstraint {
    [super bindWithTitleLabel:titleLabel descriptionLabel:descriptionLabel
     descriptionTopConstraint:topConstraint];
    [titleLabel setText:NSLocalizedString(@"upgrade.pair-sense.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"upgrade.pair-sense.desc", nil)];
}

- (void)bindWithNavigationItem:(UINavigationItem *)navItem {
    [super bindWithNavigationItem:navItem];
    
    if ([self isCancellable]) {
        NSString* title = NSLocalizedString(@"actions.cancel", nil);
        UIBarButtonItem* cancelItem = [UIBarButtonItem cancelItemWithTitle:title
                                                                     image:nil
                                                                    target:self
                                                                    action:@selector(cancel)];
        [navItem setLeftBarButtonItem:cancelItem];
    }

}

- (void)help {
    [super help];
    NSString* step = kHEMAnalyticsEventPropSensePairing;
    NSDictionary* properties = @{kHEMAnalyticsEventPropStep : step};
    [SENAnalytics track:kHEMAnalyticsEventHelp properties:properties];
}

- (void)cancel {
    [[self actionDelegate] didCancelPairingFromPresenter:self];
}

@end
