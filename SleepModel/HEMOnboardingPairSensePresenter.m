//
//  HEMOnboardingPairSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "UIBarButtonItem+HEMNav.h"

#import "HEMOnboardingPairSensePresenter.h"
#import "HEMOnboardingService.h"

@implementation HEMOnboardingPairSensePresenter

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    [super bindWithNavigationItem:navItem];
    if ([[self onbService] hasFinishedOnboarding]) {
        NSString* title = NSLocalizedString(@"actions.cancel", nil);
        UIBarButtonItem* cancelItem = [UIBarButtonItem cancelItemWithTitle:title
                                                                     image:nil
                                                                    target:self
                                                                    action:@selector(cancel)];
        [navItem setLeftBarButtonItem:cancelItem];
    }
}

#pragma mark - Actions

- (void)help {
    [super help];
    NSString* step = kHEMAnalyticsEventPropSensePairing;
    NSDictionary* properties = @{kHEMAnalyticsEventPropStep : step};
    [SENAnalytics track:kHEMAnalyticsEventOnBHelp properties:properties];
}

- (void)cancel {
    [[self actionDelegate] didCancelPairingFromPresenter:self];
}

@end
