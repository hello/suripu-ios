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

- (NSString*)nextSegueIdentifierAfterViewController:(UIViewController*)currentViewController;

- (UIViewController*)controllerToSwapInAfterViewController:(UIViewController*)currentViewController;

- (BOOL)enableBackButtonFor:(UIViewController*)currentViewController
     withPreviousController:(UIViewController*)previousController;

- (void)prepareNextController:(HEMOnboardingController*)controller
               fromController:(UIViewController*)controller;

@end