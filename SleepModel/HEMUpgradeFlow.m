//
//  HEMUpgradeFlow.m
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENServiceDevice.h>

#import "HEMUpgradeFlow.h"
#import "HEMHaveSenseViewController.h"
#import "HEMNoBLEViewController.h"
#import "HEMSensePairViewController.h"
#import "HEMUpgradePairSensePresenter.h"
#import "HEMPillDescriptionViewController.h"
#import "HEMWifiPasswordViewController.h"
#import "HEMSenseUpgradedViewController.h"
#import "HEMUpgradePillDescriptionPresenter.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBluetoothUtils.h"
#import "HEMPillSetupViewController.h"
#import "HEMPillPairViewController.h"
#import "HEMUpgradePairPillPresenter.h"

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

- (NSString*)analyticsEventPrefixForViewController:(UIViewController*)viewController {
    return HEMAnalyticsEventUpgradePrefix;
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

#pragma mark - Next using segues

- (NSString*)nextSegueIdentifierAfterViewController:(UIViewController*)currentViewController {
    NSString* nextSegueId = nil;
    if ([currentViewController isKindOfClass:[HEMHaveSenseViewController class]]) {
        if (![HEMBluetoothUtils isBluetoothOn]) {
            nextSegueId = [HEMOnboardingStoryboard noBLESegueIdentifier];
        } else {
            nextSegueId = [HEMOnboardingStoryboard pairSegueIdentifier];
        }
    } else if ([currentViewController isKindOfClass:[HEMPillDescriptionViewController class]]) {
        nextSegueId = [HEMOnboardingStoryboard pairPillSegueIdentifier];
    }
    return nextSegueId;
}

- (NSString*)nextSegueIdentifierAfterSkipping:(UIViewController *)controller {
    NSString* nextSegueId = nil;
    if ([controller isKindOfClass:[HEMPillDescriptionViewController class]]) {
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        if ([service isDFURequiredForSense]) {
            nextSegueId = [HEMOnboardingStoryboard updateSenseSegueIdentifier];
        } else if ([service isVoiceAvailable]) {
            nextSegueId = [HEMOnboardingStoryboard updateSenseSegueIdentifier];
        }
    }
    return nextSegueId;
}

- (NSString*)nextSegueIdentifierAfter:(UIViewController*)controller skip:(BOOL)skip {
    if (skip) {
        return [self nextSegueIdentifierAfterSkipping:controller];
    } else {
        return [self nextSegueIdentifierAfterViewController:controller];
    }
}

#pragma mark - Next by swapping controllers

- (UIViewController*)controllerToSwapInAfterViewController:(UIViewController*)currentViewController {
    HEMOnboardingController* controller = nil;
    
    if ([currentViewController isKindOfClass:[HEMNoBLEViewController class]]) {
        controller = (id) [HEMOnboardingStoryboard instantiateSensePairViewController];
    } else if ([currentViewController isKindOfClass:[HEMSensePairViewController class]]) {
        HEMSensePairViewController* pairVC = (id) currentViewController;
        if ([pairVC isSenseConnectedToWiFi]) {
            controller = (id) [HEMOnboardingStoryboard instantiateSenseUpgradedViewController];
        }
    } else if ([currentViewController isKindOfClass:[HEMWifiPasswordViewController class]]) {
        controller = (id) [HEMOnboardingStoryboard instantiateSenseUpgradedViewController];
    } else if ([currentViewController isKindOfClass:[HEMSenseUpgradedViewController class]]) {
        controller = (id) [HEMOnboardingStoryboard instantiatePillDescriptionViewController];
    }
    
    [self prepareNextController:controller fromController:currentViewController];
    
    return controller;
}

- (UIViewController*)controllerToSwapInAfterSkipping:(UIViewController *)controller {
    return nil;
}

- (UIViewController*)controllerToSwapInAfter:(UIViewController*)controller skip:(BOOL)skip {
    if (skip) {
        return [self controllerToSwapInAfterViewController:controller];
    } else {
        return [self controllerToSwapInAfterViewController:controller];
    }
}

#pragma mark - Completion

- (BOOL)shouldCompleteFlowAfter:(UIViewController*)controller {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    return ![service isDFURequiredForSense]
        && ![service isVoiceAvailable]
        && ([controller isKindOfClass:[HEMPillSetupViewController class]]
            || [controller isKindOfClass:[HEMPillDescriptionViewController class]]);
}

#pragma mark - Preparing next screen

- (void)prepareNextController:(HEMOnboardingController*)controller
               fromController:(UIViewController*)currentController {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    if ([controller isKindOfClass:[HEMSensePairViewController class]]) {
        HEMSensePairViewController* pairVC = (id) controller;
        HEMUpgradePairSensePresenter* presenter = [[HEMUpgradePairSensePresenter alloc] initWithOnboardingService:service];
        if ([currentController isKindOfClass:[HEMNoBLEViewController class]]) {
            [presenter setCancellable:YES];
        }
        [pairVC setPresenter:presenter];
    } else if ([controller isKindOfClass:[HEMSenseUpgradedViewController class]]) {
        [service checkFeatures];
    } else if ([controller isKindOfClass:[HEMPillDescriptionViewController class]]) {
        HEMPillDescriptionViewController* pillDescVC = (id) controller;
        SENServiceDevice* service = [SENServiceDevice sharedService];
        [pillDescVC setPresenter:[[HEMUpgradePillDescriptionPresenter alloc] initWithDeviceService:service]];
    } else if ([controller isKindOfClass:[HEMPillPairViewController class]]) {
        HEMPillPairViewController* pillPairVC = (id) controller;
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        [pillPairVC setPresenter:[[HEMUpgradePairPillPresenter alloc] initWithOnboardingService:service]];
    }
    [controller setFlow:self];
}

@end
