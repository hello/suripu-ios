//
//  HEMVoiceTutorialPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 7/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceTutorialPresenter.h"
#import "HEMScreenUtils.h"

static CGFloat const HEMVoiceTutorialInitialSenseScale = 0.6f;
static CGFloat const HEMVoiceTutorialTableBottomMargin4sScale = 0.25f;
static CGFloat const HEMVoiceTutorialAnimeDuration = 0.5f;
static CGFloat const HEMVoiceTutorialInProgressLaterBottomMargin = 21.0f;
static CGFloat const HEMVoiceTutorialInProgressTableAlpha = 0.4f;

@interface HEMVoiceTutorialPresenter()

@property (nonatomic, weak) UIView* speechContainer;
@property (nonatomic, weak) UILabel* speechTitleLabel;
@property (nonatomic, weak) UILabel* speechCommandLabel;
@property (nonatomic, weak) UILabel* speechErrorLabel;
@property (nonatomic, weak) NSLayoutConstraint* speechCommandBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint* speechErrorBottomConstraint;

@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* descriptionLabel;
@property (nonatomic, weak) UIButton* laterButton;
@property (nonatomic, weak) UIButton* continueButton;
@property (nonatomic, weak) UIImageView* senseImageView;
@property (nonatomic, weak) UIImageView* tableImageView;
@property (nonatomic, weak) NSLayoutConstraint* senseWidthConstraint;
@property (nonatomic, weak) NSLayoutConstraint* senseHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint* tableBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint* laterButtonBottomConstraint;

@property (nonatomic, assign) CGFloat origLaterBottomMargin;
@property (nonatomic, assign) CGFloat origTableBottomMargin;

@end

@implementation HEMVoiceTutorialPresenter

- (void)bindWithSpeechContainer:(UIView*)speechContainer
                     titleLabel:(UILabel*)titleLabel
                   commandLabel:(UILabel*)commandLabel
        commandBottomConstraint:(NSLayoutConstraint*)commandBottomConstraint
                     errorLabel:(UILabel*)errorLabel
          errorBottomConstraint:(NSLayoutConstraint*)errorBottomConstraint {
    
    [speechContainer setHidden:YES];
    [self setSpeechContainer:speechContainer];
    [self setSpeechTitleLabel:titleLabel];
    [self setSpeechCommandLabel:commandLabel];
    [self setSpeechCommandBottomConstraint:commandBottomConstraint];
    [self setSpeechErrorLabel:errorLabel];
    [self setSpeechErrorBottomConstraint:errorBottomConstraint];
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {
    [self setTitleLabel:titleLabel];
    [self setDescriptionLabel:descriptionLabel];
}

- (void)bindWithSenseImageView:(UIImageView*)senseImageView
           withWidthConstraint:(NSLayoutConstraint*)widthConstraint
           andHeightConstraint:(NSLayoutConstraint*)heightConstraint {
    // using constraints rather than Affine transforms b/c bottom constraint
    // doesn't respect the transform
    CGFloat scale = HEMVoiceTutorialInitialSenseScale;
    CGFloat width = [widthConstraint constant] * scale;
    CGFloat height = [heightConstraint constant] * scale;
    
    [widthConstraint setConstant:width];
    [heightConstraint setConstant:height];
    
    [self setSenseImageView:senseImageView];
    [self setSenseWidthConstraint:widthConstraint];
    [self setSenseHeightConstraint:heightConstraint];
}

- (void)bindWithTableImageView:(UIImageView*)tableImageView
          withBottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    if (HEMIsIPhone4Family()) {
        CGFloat bottom = [bottomConstraint constant];
        bottom = bottom * HEMVoiceTutorialTableBottomMargin4sScale;
        [bottomConstraint setConstant:bottom];
    }
    [self setOrigTableBottomMargin:[bottomConstraint constant]];
    [self setTableImageView:tableImageView];
    [self setTableBottomConstraint:bottomConstraint];
}

- (void)bindWithLaterButton:(UIButton*)laterButton
       withBottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [laterButton addTarget:self
                    action:@selector(finish)
          forControlEvents:UIControlEventTouchUpInside];
    [self setOrigLaterBottomMargin:[bottomConstraint constant]];
    [self setLaterButton:laterButton];
    [self setLaterButtonBottomConstraint:bottomConstraint];
}

- (void)bindWithContinueButton:(UIButton*)button {
    [button addTarget:self
               action:@selector(start)
     forControlEvents:UIControlEventTouchUpInside];
    [self setContinueButton:button];
}

#pragma mark - Actions

- (void)finish {
    [[self delegate] didFinishTutorialFrom:self];
}

- (void)start {
    [[self speechCommandLabel] sizeToFit];
    [[self speechErrorLabel] sizeToFit];
    [[self continueButton] setHidden:YES];
    [[self titleLabel] setHidden:YES];
    [[self descriptionLabel] setHidden:YES];
    [[self speechContainer] setHidden:NO];
    
    CGSize senseSize = [[self senseImageView] image].size;
    CGFloat laterBottom = HEMVoiceTutorialInProgressLaterBottomMargin;
    CGFloat commandHeight = CGRectGetHeight([[self speechCommandLabel] bounds]);
//    CGFloat errorHeight = CGRectGetHeight([[self speechErrorLabel] bounds]);
    
    [UIView animateWithDuration:HEMVoiceTutorialAnimeDuration animations:^{
        [[self speechCommandBottomConstraint] setConstant:-commandHeight];
        [[self senseWidthConstraint] setConstant:senseSize.width];
        [[self senseHeightConstraint] setConstant:senseSize.height];
        [[self laterButtonBottomConstraint] setConstant:laterBottom];
        [[self tableImageView] setAlpha:HEMVoiceTutorialInProgressTableAlpha];
        [[[self laterButton] superview] layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

@end
