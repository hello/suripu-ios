//
//  HEMZoomTransitionAnimator.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMZoomTransitionAnimator.h"

static CGFloat const kHEMZoomTransitionDuration = 0.3f;

@implementation HEMZoomTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return kHEMZoomTransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if([to isBeingPresented]) {
        [self presentWithContext:transitionContext];
    } else {
        [self dismissWithContext:transitionContext];
    }
}

- (void)presentWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIViewController* to = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* from = [context viewControllerForKey:UITransitionContextFromViewControllerKey];;
    UIView* container = [context containerView];
    
    [[to view] setAlpha:0.0f];
    [[to view] setFrame:[container bounds]];
    [[to view] setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
    [container insertSubview:[to view] aboveSubview:[from view]];
    
    [UIView animateWithDuration:kHEMZoomTransitionDuration
                     animations:^{
                         [[to view] setAlpha:1.0f];
                         [[to view] setTransform:CGAffineTransformIdentity];
                     }
                     completion:^(BOOL finished) {
                         [context completeTransition:finished];
                     }];
}

- (void)dismissWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIViewController* to = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* from = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView* container = [context containerView];
    
    [[to view] setFrame:[container bounds]];
    [container insertSubview:[to view] belowSubview:[from view]];
    
    [UIView animateWithDuration:kHEMZoomTransitionDuration
                     animations:^{
                         [[from view] setAlpha:0.0f];
                         [[from view] setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
                     }
                     completion:^(BOOL finished) {
                         [context completeTransition:finished];
                     }];
    
}

@end
