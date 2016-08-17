//
//  HEMPairPillPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMPillDescriptionPresenter;

@protocol HEMPillDescriptionDelegate <NSObject>

- (void)skip:(BOOL)skip fromPresenter:(HEMPillDescriptionPresenter*)presenter;

@end

@interface HEMPillDescriptionPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMPillDescriptionDelegate> delegate;
@property (nonatomic, weak, readonly) UIView* activityContainerView; // for subclasses

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel;

- (void)bindWithContinueButton:(UIButton*)continueButton;

- (void)bindWithLaterButton:(UIButton*)laterButton;

- (void)bindWithActivityContainerView:(UIView*)containerView;

/**
 * @discussion
 * Should not call directly.  It is meant for subclasses to override.  By default,
 * this will simply call the delegate method to continue
 */
- (void)proceed;

@end
