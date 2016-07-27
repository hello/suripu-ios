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

@interface HEMVoiceTutorialPresenter()

@property (nonatomic, weak) UIButton* laterButton;
@property (nonatomic, weak) UIButton* continueButton;
@property (nonatomic, weak) UIImageView* senseImageView;
@property (nonatomic, weak) UIImageView* tableImageView;
@property (nonatomic, weak) NSLayoutConstraint* senseWidthConstraint;
@property (nonatomic, weak) NSLayoutConstraint* senseHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint* tableBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint* laterButtonBottomConstraint;

@end

@implementation HEMVoiceTutorialPresenter

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
    [self setTableImageView:tableImageView];
    [self setTableBottomConstraint:bottomConstraint];
}

- (void)bindWithLaterButton:(UIButton*)laterButton
       withBottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [laterButton addTarget:self
                    action:@selector(finish)
          forControlEvents:UIControlEventTouchUpInside];
    [self setLaterButton:laterButton];
    [self setLaterButtonBottomConstraint:bottomConstraint];
}

- (void)bindWithContinueButton:(UIButton*)button {
    [button addTarget:self
               action:@selector(finish)
     forControlEvents:UIControlEventTouchUpInside];
    [self setContinueButton:button];
}

#pragma mark - Actions

- (void)finish {
    [[self delegate] didFinishTutorialFrom:self];
}

@end
