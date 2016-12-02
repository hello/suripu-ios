//
//  HEMTransitionDelegate.m
//  Sense
//
//  Created by Jimmy Lu on 2/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import "Sense-Swift.h"

#import "HEMTransitionDelegate.h"

CGFloat const HEMTransitionDimmingViewMaxAlpha = 0.7f;
static CGFloat const HEMTransitionDefaultDuration = 0.5f;

@interface HEMTransitionDelegate()

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, assign) BOOL previouslyShowingStatusBar;
@property (nonatomic, strong) UIView* dimmingView;

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

- (UIView*)dimmingViewWithContext:(id<UIViewControllerContextTransitioning>)context {
    if (!_dimmingView) {
        UIView* containerView = [context containerView];
        CGRect containerBounds = [containerView bounds];
        
        UIView* dimmingView = [[UIView alloc] initWithFrame:containerBounds];
        [dimmingView setAlpha:0.0f];
        [dimmingView setBackgroundColor:[UIColor blackColor]];
        _dimmingView = dimmingView;
    }
    return _dimmingView;
}

- (void)showStatusBar:(BOOL)show {
    RootViewController* root = [RootViewController currentRootViewController];
    if (show) {
        [root showStatusBar];
    } else {
        [root hideStatusBar];
    }
}

- (BOOL)isStatusBarShowing {
    RootViewController* root = [RootViewController currentRootViewController];
    return ![root isStatusBarHidden];
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
