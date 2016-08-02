//
//  HEMVoiceTutorialPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 7/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMVoiceTutorialPresenter;
@class HEMVoiceService;

@protocol HEMVoiceTutorialDelegate <NSObject>

- (void)didFinishTutorialFrom:(HEMVoiceTutorialPresenter*)presenter;
- (void)showController:(UIViewController*)controller fromPresenter:(HEMVoiceTutorialPresenter*)presenter;

@end

@interface HEMVoiceTutorialPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMVoiceTutorialDelegate> delegate;

- (instancetype)initWithVoiceService:(HEMVoiceService*)voiceService NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (void)bindWithSpeechContainer:(UIView*)speechContainer
      containerBottomConstraint:(NSLayoutConstraint*)containerBottomConstraint
                     titleLabel:(UILabel*)titleLabel
                   commandLabel:(UILabel*)commandLabel
        commandBottomConstraint:(NSLayoutConstraint*)commandBottomConstraint
                     errorLabel:(UILabel*)errorLabel
          errorBottomConstraint:(NSLayoutConstraint*)errorBottomConstraint;
- (void)bindWithNavigationItem:(UINavigationItem*)navItem;
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
