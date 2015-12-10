//
//  HEMInsightTransition.m
//  Sense
//
//  Created by Jimmy Lu on 12/7/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMInsightTransition.h"
#import "HEMInsightTransitionView.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMURLImageView.h"

static CGFloat const HEMInsightTransitionImageHeight = 188.0f;
static CGFloat const HEMInsightTransitionDuration = 0.3f;

@interface HEMInsightTransition()

@property (nonatomic, strong) HEMInsightTransitionView* transitionView;
@property (nonatomic, assign) CGRect startFrame;
@property (nonatomic, assign) CGFloat originalImageHeight;

@end

@implementation HEMInsightTransition

- (void)expandFrom:(HEMInsightCollectionViewCell*)cell withRelativeFrame:(CGRect)frame {
    if (![self transitionView]) {
        [self setTransitionView:[HEMInsightTransitionView transitionViewFromCell:cell]];
    } else {
        [[self transitionView] copyFromCell:cell];
    }
    
    [[self transitionView] setFrame:frame];
    [self setStartFrame:frame];
    [self setOriginalImageHeight:CGRectGetHeight([[cell uriImageView] bounds])];
}

- (void)animatePresentationWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIView* containerView = [context containerView];
    UIViewController* toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* toView = [toVC view];
    [toView setAlpha:0.0f];
    [toView setFrame:[containerView bounds]];
    [containerView addSubview:toView];
    
    [containerView addSubview:[self dimmingViewWithContext:context]];
    [containerView addSubview:[self transitionView]];
    
    [UIView animateWithDuration:HEMInsightTransitionDuration
                     animations:^{
                         [self setTimelineVisible:NO animated:NO];
                         [self showStatusBar:NO];
                         [[self transitionView] expand:[containerView bounds].size
                                           imageHeight:HEMInsightTransitionImageHeight];
                         [[self dimmingViewWithContext:context] setAlpha:HEMTransitionDimmingViewMaxAlpha];
                     }
                     completion:^(BOOL finished) {
                         [toView setAlpha:1.0f];
                         
                         [[self transitionView] removeFromSuperview];
                         [[self dimmingViewWithContext:context] removeFromSuperview];
                         
                         [context completeTransition:finished];
                     }];
}

- (void)animateDismissalWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIViewController* fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView* fromView = [fromVC view];
    
    UIView* containerView = [context containerView];
    [containerView insertSubview:[self dimmingViewWithContext:context] belowSubview:fromView];
    [containerView insertSubview:[self transitionView] belowSubview:fromView];
    
    [fromView removeFromSuperview];
    
    [UIView animateWithDuration:HEMInsightTransitionDuration
                     animations:^{
                         [fromView setFrame:[self startFrame]];
                         [[self transitionView] shrink:[self startFrame] imageHeight:[self originalImageHeight]];
                         [[self dimmingViewWithContext:context] setAlpha:0.0f];
                         [self setTimelineVisible:YES animated:NO];
                     }
                     completion:^(BOOL finished) {
                         [[self transitionView] removeFromSuperview];
                         [[self dimmingViewWithContext:context] removeFromSuperview];
                         [self showStatusBar:YES];

                         [context completeTransition:finished];
                     }];
}

@end
