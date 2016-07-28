//
//  HEMVoiceTutorialPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 7/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceTutorialPresenter.h"
#import "HEMScreenUtils.h"
#import "HEMStyle.h"

static CGFloat const HEMVoiceTutorialInitialSenseScale = 0.6f;
static CGFloat const HEMVoiceTutorialTableBottomMargin4sScale = 0.25f;
static CGFloat const HEMVoiceTutorialAnimeDuration = 0.3f;
static CGFloat const HEMVoiceTutorialInProgressLaterBottomMargin = 21.0f;
static CGFloat const HEMVoiceTutorialInProgressTableBottomMargin = 32.0f;
static CGFloat const HEMVoiceTutorialInProgressTableAlpha = 0.4f;
static CGFloat const HEMVoiceTutorialInProgressRingAlpha = 0.04f;
static CGFloat const HEMVoiceTutorialInProgressOuterRingSize = 236.0f;
static CGFloat const HEMVoiceTutorialInProgressMiddleRingSize = 192.0f;
static CGFloat const HEMVoiceTutorialInProgressInnerRingSize = 146.0f;
static CGFloat const HEMVoiceTutorialRingAnimeDelay = 0.1f;
static CGFloat const HEMVoiceTutorialRingAnimeDuration = 0.5f;

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

@property (nonatomic, weak) CALayer* outerSenseRing;
@property (nonatomic, weak) CALayer* middleSenseRing;
@property (nonatomic, weak) CALayer* innerSenseRing;

@end

@implementation HEMVoiceTutorialPresenter

- (void)bindWithSpeechContainer:(UIView*)speechContainer
                     titleLabel:(UILabel*)titleLabel
                   commandLabel:(UILabel*)commandLabel
        commandBottomConstraint:(NSLayoutConstraint*)commandBottomConstraint
                     errorLabel:(UILabel*)errorLabel
          errorBottomConstraint:(NSLayoutConstraint*)errorBottomConstraint {
    
    [speechContainer setHidden:YES];
    [commandLabel setFont:[UIFont h4]];
    [commandLabel setTextColor:[UIColor grey6]];
    [errorLabel setFont:[UIFont h4]];
    [errorLabel setTextColor:[UIColor grey6]];
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

#pragma mark - Presenter Events

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self animateSenseRings];
}

#pragma mark - Ring animation

- (CABasicAnimation*)fadeAnimationWithDelay:(CGFloat)delay
                                       from:(CGFloat)from
                                         to:(CGFloat)to {
    CABasicAnimation* fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fade setFromValue:@(from)];
    [fade setToValue:@(to)];
    [fade setBeginTime:delay];
    [fade setDuration:HEMVoiceTutorialRingAnimeDuration];
    [fade setFillMode:kCAFillModeForwards];
    return fade;
}

- (CAShapeLayer*)senseRingLayerWithSize:(CGFloat)size {
    
    CGPoint sensePosition = [[[self senseImageView] layer] position];
    CGRect ringFrame = CGRectZero;
    ringFrame.size = CGSizeMake(size, size);
    
    CAShapeLayer* ring = [CAShapeLayer layer];
    [ring setPath:[[UIBezierPath bezierPathWithOvalInRect:ringFrame] CGPath]];
    [ring setFrame:ringFrame];
    [ring setPosition:sensePosition];
    [ring setFillColor:[[UIColor grey4] CGColor]];
    [ring fillColor];
    [ring setOpacity:0.0f];
    
    return ring;
}

- (void)addAnimationTo:(CALayer*)ring
       withFadeInDelay:(CGFloat)fadeInDelay
          fadeOutDelay:(CGFloat)fadeOutDelay {
    [ring removeAllAnimations];
    
    CGFloat totalDuration = fadeOutDelay + HEMVoiceTutorialRingAnimeDuration;
    CGFloat fullAlpha = HEMVoiceTutorialInProgressRingAlpha;
    
    CABasicAnimation* fadeIn = [self fadeAnimationWithDelay:fadeInDelay
                                                       from:0.0f
                                                         to:fullAlpha];
    CABasicAnimation* fadeOut = [self fadeAnimationWithDelay:fadeInDelay
                                                        from:fullAlpha
                                                          to:0.0f];
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    [group setAnimations:@[fadeIn, fadeOut]];
    [group setRepeatCount:MAXFLOAT];
    [group setDuration:totalDuration];
    
    [ring addAnimation:group forKey:@"fade"];
}

- (void)animateSenseRings {
    if (![self outerSenseRing]
        && ![self middleSenseRing]
        && ![self innerSenseRing]) {
        UIView* ringContainer = [[self senseImageView] superview];
        CALayer* ringContainerLayer = [ringContainer layer];
        CALayer* senseLayer = [[self senseImageView] layer];
        
        CGFloat size = HEMVoiceTutorialInProgressOuterRingSize;
        CAShapeLayer* ring = [self senseRingLayerWithSize:size];
        [ringContainerLayer insertSublayer:ring below:senseLayer];
        [self setOuterSenseRing:ring];
        
        size = HEMVoiceTutorialInProgressMiddleRingSize;
        ring = [self senseRingLayerWithSize:size];
        [ringContainerLayer insertSublayer:ring below:senseLayer];
        [self setMiddleSenseRing:ring];
        
        size = HEMVoiceTutorialInProgressInnerRingSize;
        ring = [self senseRingLayerWithSize:size];
        [ringContainerLayer insertSublayer:ring below:senseLayer];
        [self setInnerSenseRing:ring];
    }
    
    CGFloat fadeInDelay = HEMVoiceTutorialRingAnimeDelay * 3;
    CGFloat fadeOutDelay = fadeInDelay + HEMVoiceTutorialRingAnimeDuration;
    [self addAnimationTo:[self outerSenseRing]
         withFadeInDelay:fadeInDelay
            fadeOutDelay:fadeOutDelay];
    
    fadeInDelay = HEMVoiceTutorialRingAnimeDelay * 2;
    [self addAnimationTo:[self middleSenseRing]
         withFadeInDelay:fadeInDelay
            fadeOutDelay:fadeOutDelay];
    
    fadeInDelay = HEMVoiceTutorialRingAnimeDelay;
    [self addAnimationTo:[self innerSenseRing]
         withFadeInDelay:fadeInDelay
            fadeOutDelay:fadeOutDelay];
}

#pragma mark - Actions

- (void)finish {
    [[self delegate] didFinishTutorialFrom:self];
}

- (void)start {
    [[self speechCommandLabel] sizeToFit];
    [[self speechErrorLabel] setHidden:YES];
    [[self continueButton] setHidden:YES];
    [[self titleLabel] setHidden:YES];
    [[self descriptionLabel] setHidden:YES];
    [[self speechContainer] setHidden:NO];
    
    CGSize senseSize = [[self senseImageView] image].size;
    CGFloat laterBottom = HEMVoiceTutorialInProgressLaterBottomMargin;
    
    [UIView animateWithDuration:HEMVoiceTutorialAnimeDuration animations:^{
        [[self speechCommandBottomConstraint] setConstant:0];
        [[self senseWidthConstraint] setConstant:senseSize.width];
        [[self senseHeightConstraint] setConstant:senseSize.height];
        [[self laterButtonBottomConstraint] setConstant:laterBottom];
        [[self tableBottomConstraint] setConstant:-HEMVoiceTutorialInProgressTableBottomMargin];
        [[self tableImageView] setAlpha:HEMVoiceTutorialInProgressTableAlpha];
        [[[self laterButton] superview] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self animateSenseRings];
    }];
}

@end
