//
//  HEMNewAccountPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 5/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMNewAccountPresenter;
@class HEMOnboardingService;

@protocol HEMNewAccountPresenterDelegate

- (void)showError:(NSString*)errorMessage title:(NSString*)title from:(HEMNewAccountPresenter*)presenter;
- (void)proceedFrom:(HEMNewAccountPresenter*)presenter;

@end

@interface HEMNewAccountPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMNewAccountPresenterDelegate> delegate;

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService;

- (void)bindWithCollectionView:(UICollectionView*)collectionView
           andBottomConstraint:(NSLayoutConstraint*)bottomConstraint;

- (void)bindWithNextButton:(UIButton*)button;

- (void)bindWithActivityContainerView:(UIView*)activityContainerView;

@end
