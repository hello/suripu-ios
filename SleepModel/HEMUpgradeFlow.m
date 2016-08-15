//
//  HEMUpgradeFlow.m
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMUpgradeFlow.h"
#import "HEMHaveSenseViewController.h"
#import "HEMNoBLEViewController.h"
#import "HEMSensePairViewController.h"
#import "HEMUpgradePairSensePresenter.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBluetoothUtils.h"

@implementation HEMUpgradeFlow

- (instancetype)init {
    self = [super init];
    if (self) {
        // we need to do this to warm up the radio to check later
        BOOL on = [HEMBluetoothUtils isBluetoothOn];
        DDLogVerbose(@"is bluetooth on %@", on ? @"y" : @"n");
    }
    return self;
}

- (NSString*)nextSegueIdentifierAfterViewController:(UIViewController*)currentViewController {
    NSString* nextSegueId = nil;
    if ([currentViewController isKindOfClass:[HEMHaveSenseViewController class]]) {
        if (![HEMBluetoothUtils isBluetoothOn]) {
            nextSegueId = [HEMOnboardingStoryboard noBLESegueIdentifier];
        } else {
            nextSegueId = [HEMOnboardingStoryboard pairSegueIdentifier];
        }
    } // NO BLE should call controllerToSwapInAfterViewController: instead
    return nextSegueId;
}

- (UIViewController*)controllerToSwapInAfterViewController:(UIViewController*)currentViewController {
    HEMOnboardingController* controller = nil;
    if ([currentViewController isKindOfClass:[HEMNoBLEViewController class]]) {
        HEMSensePairViewController* pairVC = [HEMOnboardingStoryboard instantiateSensePairViewController];
        [self prepareNextController:pairVC fromController:currentViewController];
        controller = pairVC;
    } else if ([currentViewController isKindOfClass:[HEMSensePairViewController class]]) {
        HEMSensePairViewController* pairVC = (id) currentViewController;
        if ([pairVC isSenseConnectedToWiFi]) {
            controller = (id) [HEMOnboardingStoryboard instantiateSenseUpgradedViewController];
        }
    }
    if (controller) {
        [controller setFlow:self];
    }
    return controller;
}

- (BOOL)enableBackButtonFor:(UIViewController*)currentViewController
     withPreviousController:(UIViewController*)previousController {
    BOOL enable = YES;
    if ([previousController isKindOfClass:[HEMNoBLEViewController class]]
        && [currentViewController isKindOfClass:[HEMSensePairViewController class]]) {
        enable = NO;
    }
    return enable;
}

- (void)prepareNextController:(HEMOnboardingController*)controller
               fromController:(UIViewController*)currentController {
    if ([controller isKindOfClass:[HEMSensePairViewController class]]) {
        HEMSensePairViewController* pairVC = (id) controller;
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        HEMUpgradePairSensePresenter* presenter = [[HEMUpgradePairSensePresenter alloc] initWithOnboardingService:service];
        if ([currentController isKindOfClass:[HEMNoBLEViewController class]]) {
            [presenter setCancellable:YES];
        }
        [pairVC setPresenter:presenter];
    }
    [controller setFlow:self];
}

@end
