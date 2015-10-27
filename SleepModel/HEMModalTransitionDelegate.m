//
//  HEMModalTransitionDelegate.m
//  Sense
//
//  Created by Jimmy Lu on 10/26/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMModalTransitionDelegate.h"
#import "HEMRootViewController.h"

@interface HEMModalTransitionDelegate()

@property (nonatomic, weak)   UIView *dimmingView;
@property (nonatomic, assign) UIWindowLevel originalWindowLevel;
@property (nonatomic, assign) BOOL previouslyShowingStatusBar;

@end

@implementation HEMModalTransitionDelegate

- (void)animatePresentationWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIView* containerView = [context containerView];
    UIViewController* fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [self saveAndUpdateStatusBarAppearance];
    
    switch ([self transitionStyle]) {
        case HEMModalTransitionStyleNormal:
        default:
            [self presentNormallyWithContext:context
                                 inContainer:containerView
                                        from:fromVC
                                          to:toVC];
            break;
    }
}

- (void)animateDismissalWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIView* containerView = [context containerView];
    UIViewController* fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    switch ([self transitionStyle]) {
        case HEMModalTransitionStyleNormal:
        default: {
            [self dismissNormallyWithContext:context
                                 inContainer:containerView
                                        from:fromVC
                                          to:toVC
                                  completion:^{
                                      [self restoreStatusBarAppearance];
                                  }];
            break;
        }
    }
}

#pragma mark - Status bar handling

- (void)saveAndUpdateStatusBarAppearance {
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    [self setPreviouslyShowingStatusBar:![rootVC isStatusBarHidden]];
    
    if ([self wantsStatusBar] != [self previouslyShowingStatusBar]) {
        if ([self wantsStatusBar]) {
            [rootVC showStatusBar];
        } else {
            [rootVC hideStatusBar];
        }
    }
}

- (void)restoreStatusBarAppearance {
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    if ([self previouslyShowingStatusBar]) {
        [rootVC showStatusBar];
    } else {
        [rootVC hideStatusBar];
    }
}

#pragma mark - Transition styles

- (void)presentNormallyWithContext:(id<UIViewControllerContextTransitioning>)context
                       inContainer:(UIView*)containerView
                              from:(UIViewController*)fromController
                                to:(UIViewController*)toController {
    
    CGRect containerBounds = [containerView bounds];
    
    UIView* dimmingView = [[UIView alloc] initWithFrame:containerBounds];
    [dimmingView setAlpha:0.0f];
    [dimmingView setBackgroundColor:[UIColor blackColor]];
    [containerView addSubview:dimmingView];
    [self setDimmingView:dimmingView];
    
    UIView* toView = [toController view];
    [containerView addSubview:toView];
    
    CGRect toFrame = [toView frame];
    toFrame.origin.y = CGRectGetHeight(containerBounds);
    [toView setFrame:toFrame];
    
    [UIView animateWithDuration:[self duration]
                     animations:^{
                         CGRect frame = [toView frame];
                         frame.origin = CGPointZero;
                         [toView setFrame:frame];
                         [[self dimmingView] setAlpha:0.7f];
                     }
                     completion:^(BOOL finished) {
                         [context completeTransition:finished];
                     }];
}

- (void)dismissNormallyWithContext:(id<UIViewControllerContextTransitioning>)context
                       inContainer:(UIView*)containerView
                              from:(UIViewController*)fromViewController
                                to:(UIViewController*)toController completion:(void(^)(void))completion {
    
    UIView* fromView = [fromViewController view];
    CGRect updateFrame = [fromView frame];
    updateFrame.origin.y = CGRectGetHeight([containerView bounds]);
    
    [UIView animateWithDuration:[self duration]
                     animations:^{
                         [fromView setFrame:updateFrame];
                         [[self dimmingView] setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [fromView removeFromSuperview];
                         [context completeTransition:finished];
                         completion ();
                     }];
}

@end
