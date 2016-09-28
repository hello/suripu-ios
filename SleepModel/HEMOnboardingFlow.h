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

+ (UIViewController*)rootViewControllerForFlow;
- (NSString*)nextSegueIdentifierAfter:(UIViewController*)controller skip:(BOOL)skip;
- (UIViewController*)controllerToSwapInAfter:(UIViewController*)controller skip:(BOOL)skip;
- (BOOL)shouldCompleteFlowAfter:(UIViewController*)controller;
- (void)prepareNextController:(HEMOnboardingController*)controller
               fromController:(UIViewController*)controller;
- (NSString*)analyticsEventPrefix;

@end