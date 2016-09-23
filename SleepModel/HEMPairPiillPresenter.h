//
//  HEMPairPiillPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/16/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMOnboardingService;
@class HEMEmbeddedVideoView;
@class HEMActivityCoverView;
@class HEMActionButton;
@class HEMPairPiillPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMPairPillPresenterDelegate <NSObject>

- (void)completePairing:(BOOL)skipped fromPresenter:(HEMPairPiillPresenter*)presenter;
- (void)showHelpPage:(NSString*)helpPage fromPresenter:(HEMPairPiillPresenter*)presenter;

@end

@interface HEMPairPiillPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMPairPillPresenterDelegate> delegate;
@property (nonatomic, copy) NSString* analyticsHelpEventName;
@property (nonatomic, assign, getter=isCancellable) BOOL cancellable;

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onboardingService;

- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel;
- (void)bindWithContinueButton:(HEMActionButton*)continueButton
           withWidthConstraint:(NSLayoutConstraint*)widthConstraint;
- (void)bindWithSkipButton:(UIButton*)skipButton;
- (void)bindWithEmbeddedVideoView:(HEMEmbeddedVideoView*)embeddedView;
- (void)bindWithActivityView:(HEMActivityCoverView*)activityView;
- (void)bindWithStatusLabel:(UILabel*)statusLabel;
- (void)bindWithNavigationItem:(UINavigationItem*)navItem;
- (void)bindWithContentContainerView:(UIView*)contentView;
- (void)trackEvent:(NSString*)event withProperties:(NSDictionary*)props;

@end

NS_ASSUME_NONNULL_END