//
//  HEMUpgradeFlow.m
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMUpgradeFlow.h"
#import "HEMHaveSenseViewController.h"
#import "HEMUpgradePairSensePresenter.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingStoryboard.h"

@implementation HEMUpgradeFlow

- (HEMPresenter*)presenterForNextViewController:(UIViewController*)controller
                      fromCurrentViewController:(UIViewController*)currentViewController {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    return [[HEMUpgradePairSensePresenter alloc] initWithOnboardingService:service];
}

- (NSString*)nextSegueIdentifierAfterViewController:(UIViewController*)currentViewController {
    NSString* nextSegueId = nil;
    if ([currentViewController isKindOfClass:[HEMHaveSenseViewController class]]) {
        nextSegueId = [HEMOnboardingStoryboard pairSegueIdentifier];
    }
    return nextSegueId;
}

@end
