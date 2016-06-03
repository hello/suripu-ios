//
//  HEMSignInNavBarPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 5/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMOnboardingController;
@class HEMSignInNavBarPresenter;

@protocol HEMSignInNavBarDelegate <NSObject>

- (void)showForgotPasswordScreenFrom:(HEMSignInNavBarPresenter*)presenter;
- (void)dismissControllerFrom:(HEMSignInNavBarPresenter*)presenter;

@end

@interface HEMSignInNavBarPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMSignInNavBarDelegate> delegate;

- (void)bindWithOnboardingController:(HEMOnboardingController*)onbController;

@end
