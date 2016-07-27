//
//  HEMVoiceTutorialPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 7/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMVoiceTutorialPresenter;

@protocol HEMVoiceTutorialDelegate <NSObject>

- (void)didFinishTutorialFrom:(HEMVoiceTutorialPresenter*)presenter;

@end

@interface HEMVoiceTutorialPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMVoiceTutorialDelegate> delegate;

- (void)bindWithSpeechContainer:(UIView*)speechContainer
                     titleLabel:(UILabel*)titleLabel
                   commandLabel:(UILabel*)commandLabel
        commandBottomConstraint:(NSLayoutConstraint*)commandBottomConstraint
                     errorLabel:(UILabel*)errorLabel
          errorBottomConstraint:(NSLayoutConstraint*)errorBottomConstraint;
- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel;
- (void)bindWithSenseImageView:(UIImageView*)senseImageView
           withWidthConstraint:(NSLayoutConstraint*)widthConstraint
           andHeightConstraint:(NSLayoutConstraint*)heightConstraint;
- (void)bindWithTableImageView:(UIImageView*)tableImageView
          withBottomConstraint:(NSLayoutConstraint*)bottomConstraint;
- (void)bindWithLaterButton:(UIButton*)laterButton
       withBottomConstraint:(NSLayoutConstraint*)bottomConstraint;
- (void)bindWithContinueButton:(UIButton*)button;

@end
