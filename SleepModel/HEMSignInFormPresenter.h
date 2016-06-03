//
//  HEMSignInFormPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 5/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMOnboardingService;
@class HEMAccountService;
@class HEMActionButton;
@class HEMSignInFormPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMSignInFormDelegate <NSObject>

- (void)showErrorTitle:(NSString*)title
               message:(NSString*)message
                  from:(HEMSignInFormPresenter*)presenter;

@end

@interface HEMSignInFormPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMSignInFormDelegate> delegate;

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService
                           accountService:(HEMAccountService*)accountService;
- (void)bindWithCollectionView:(UICollectionView*)collectionView
              bottomConstraint:(NSLayoutConstraint*)bottomConstraint;
- (void)bindWithSignInButton:(HEMActionButton*)signInButton;
- (void)bindWithActivityContainer:(UIView*)activityContainer;

@end

NS_ASSUME_NONNULL_END