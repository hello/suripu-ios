//
//  HEMOnboardingFlow.h
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

@class HEMPresenter;

@protocol HEMOnboardingFlow <NSObject>

- (HEMPresenter*)presenterForNextViewController:(UIViewController*)controller
                      fromCurrentViewController:(UIViewController*)currentViewController;

- (NSString*)nextSegueIdentifierAfterViewController:(UIViewController*)currentViewController;

- (UIViewController*)controllerToSwapInAfterViewController:(UIViewController*)currentViewController;

- (BOOL)enableBackButtonFor:(UIViewController*)currentViewController
     withPreviousController:(UIViewController*)previousController;

@end