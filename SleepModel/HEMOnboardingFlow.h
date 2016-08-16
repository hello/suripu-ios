//
//  HEMOnboardingFlow.h
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

@class HEMPresenter;
@class HEMOnboardingController;

@protocol HEMOnboardingFlow <NSObject>

- (BOOL)enableBackButtonFor:(UIViewController*)currentViewController
     withPreviousController:(UIViewController*)previousController;

- (NSString*)analyticsEventPrefixForViewController:(UIViewController*)viewController;

- (NSString*)nextSegueIdentifierAfterViewController:(UIViewController*)currentViewController;
- (NSString*)nextSegueIdentifierAfterSkipping:(UIViewController*)controller;

- (UIViewController*)controllerToSwapInAfterViewController:(UIViewController*)currentViewController;
- (UIViewController*)controllerToSwapInAfterSkipping:(UIViewController*)controller;

- (void)prepareNextController:(HEMOnboardingController*)controller
               fromController:(UIViewController*)controller;

@end