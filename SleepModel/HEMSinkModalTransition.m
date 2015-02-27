//
//  HEMSinkAnimationTransitionDelegate.m
//  Sense
//
//  Created by Jimmy Lu on 12/17/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "HEMSinkModalTransition.h"

@interface HEMSinkModalTransition()

@end

@implementation HEMSinkModalTransition

- (void)animatePresentationWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIView* containerView = [context containerView];
    UIViewController* toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    [[toVC view] setAlpha:0.0f];
    [containerView addSubview:[toVC view]];
    
    [UIView animateWithDuration:[self duration]
                     animations:^{
                         [[toVC view] setAlpha:1.0f];
                         // must transform the layer rather than the actual view b/c applying a transform
                         // to the actual view triggers layoutSubviews, which conequently causes autolayout
                         // constraints to modify frames (not bounds) of the view, which is a no-no when
                         // applying transforms.  What makes it worse is that depending on the OS version,
                         // the transform seems to trigger layoutSubviews immediately after causing the
                         // animation to do unexpected (additional) movements... happens in iOS 7, but not iOS8
                         [[[self sinkView] layer] setTransform:CATransform3DMakeScale(0.9f, 0.9f, 0.9f)];
                     }
                     completion:^(BOOL finished) {
                         [context completeTransition:YES];
                     }];
}

- (void)animateDismissalWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIViewController* fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView* fromView = [fromVC view];
    
    [UIView animateWithDuration:[self duration]
                     animations:^{
                         [fromView setAlpha:0.0f];
                         [[[self sinkView] layer] setTransform:CATransform3DIdentity];
                     }
                     completion:^(BOOL finished) {
                         [fromView removeFromSuperview];
                         [context completeTransition:YES];
                     }];
}

@end
