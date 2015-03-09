//
//  HEMTransitionDelegate.m
//  Sense
//
//  Created by Jimmy Lu on 2/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMTransitionDelegate.h"

static CGFloat const HEMTransitionDefaultDuration = 0.5f;

@interface HEMTransitionDelegate()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation HEMTransitionDelegate

- (id)init {
    self = [super init];
    if (self) {
        _duration = HEMTransitionDefaultDuration;
    }
    return self;
}

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
    return [self duration];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    if ([self presenting]) {
        [self animatePresentationWithContext:transitionContext];
    } else {
        [self animateDismissalWithContext:transitionContext];
    }
    
}

- (void)animatePresentationWithContext:(id<UIViewControllerContextTransitioning>)context {}
- (void)animateDismissalWithContext:(id<UIViewControllerContextTransitioning>)context {}


@end
