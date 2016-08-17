//
//  HEMOnboardingFlow.h
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

@class HEMPresenter;
@class HEMOnboardingController;

@protocol HEMSetupFlow <NSObject>

- (BOOL)enableBackButtonFor:(UIViewController*)currentViewController
     withPreviousController:(UIViewController*)previousController;

- (NSString*)analyticsEventPrefixForViewController:(UIViewController*)viewController;

- (NSString*)nextSegueIdentifierAfter:(UIViewController*)controller skip:(BOOL)skip;
- (UIViewController*)controllerToSwapInAfter:(UIViewController*)controller skip:(BOOL)skip;
- (BOOL)shouldCompleteFlowAfter:(UIViewController*)controller;
- (void)prepareNextController:(HEMOnboardingController*)controller
               fromController:(UIViewController*)controller;

@end