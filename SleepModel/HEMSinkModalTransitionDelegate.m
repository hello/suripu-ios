//
//  HEMSinkAnimationTransitionDelegate.m
//  Sense
//
//  Created by Jimmy Lu on 12/17/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "UIView+HEMSnapshot.h"
#import "HEMSinkModalTransitionDelegate.h"

static CGFloat const HEMSinkAnimationDuration = 0.5f;

@interface HEMSinkModalTransitionDelegate()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation HEMSinkModalTransitionDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    [self setPresenting:NO];
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    [self setPresenting:YES];
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return HEMSinkAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    if ([self presenting]) {
        [self animatePresentationWithContext:transitionContext];
    } else {
        [self animateDismissalWithContext:transitionContext];
    }

}

- (void)animatePresentationWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIView* containerView = [context containerView];
    UIViewController* toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    [[toVC view] setAlpha:0.0f];
    [containerView addSubview:[toVC view]];
    
    [UIView animateWithDuration:HEMSinkAnimationDuration
                     animations:^{
                         [[toVC view] setAlpha:1.0f];
                         [[self sinkView] setTransform:CGAffineTransformMakeScale(0.9f, 0.9f)];
                     }
                     completion:^(BOOL finished) {
                         [context completeTransition:YES];
                     }];
}

- (void)animateDismissalWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIViewController* fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView* fromView = [fromVC view];
    
    [UIView animateWithDuration:HEMSinkAnimationDuration
                     animations:^{
                         [fromView setAlpha:0.0f];
                         [[self sinkView] setTransform:CGAffineTransformIdentity];
                     }
                     completion:^(BOOL finished) {
                         [fromView removeFromSuperview];
                         [context completeTransition:YES];
                     }];
}

@end
