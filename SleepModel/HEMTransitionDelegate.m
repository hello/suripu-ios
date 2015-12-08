//
//  HEMTransitionDelegate.m
//  Sense
//
//  Created by Jimmy Lu on 2/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMTransitionDelegate.h"
#import "HEMRootViewController.h"

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

- (void)setTimelineVisible:(BOOL)visible animated:(BOOL)animated {
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    [rootVC setPaneVisible:visible animated:animated];
}

- (void)showStatusBar:(BOOL)show {
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    if (show) {
        [rootVC showStatusBar];
    } else {
        [rootVC hideStatusBar];
    }
}

- (BOOL)isStatusBarShowing {
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    return ![rootVC isStatusBarHidden];
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
