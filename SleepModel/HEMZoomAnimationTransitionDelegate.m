//
//  HEMZoomAnimationTransitionDelegate.m
//  Sense
//
//  Created by Delisa Mason on 12/10/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMZoomAnimationTransitionDelegate.h"
#import "HEMSleepHistoryViewController.h"
#import "UIView+HEMSnapshot.h"

@implementation HEMZoomAnimationTransitionDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.75f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *containerView = [transitionContext containerView];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];

    toViewController.view.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height);
    toViewController.view.layer.zPosition = 0;
    fromViewController.view.layer.zPosition = 1;
    [containerView addSubview:toViewController.view];
    toViewController.view.frame = finalFrame;

    if ([toViewController isKindOfClass:[HEMSleepHistoryViewController class]]) {
        [self zoomOutToController:toViewController fromController:fromViewController transition:transitionContext];
    } else if ([fromViewController isKindOfClass:[HEMSleepHistoryViewController class]]) {
        [self zoomInFromController:fromViewController transition:transitionContext];
    } else {
        [transitionContext completeTransition:YES];
    }
}

- (void)zoomInFromController:(UIViewController*)fromViewController
                  transition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [self animateView:fromViewController.view
       verticalOffset:68.f
     horizontalOffset:6.f
            transform:CATransform3DMakeScale(2.f, 2.f, 1.f)
      otherAnimations:NULL
           completion:^{
               [transitionContext completeTransition:YES];
           }];
}

- (void)zoomOutToController:(UIViewController*)toViewController
             fromController:(UIViewController*)fromViewController
                 transition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIImage* snapshot = [fromViewController.view snapshot];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:snapshot];
    [toViewController.view.layer insertSublayer:imageView.layer
                                        atIndex:(uint)toViewController.view.layer.sublayers.count];
    toViewController.view.layer.transform = CATransform3DMakeScale(1.4f, 1.4f, 1.f);
    imageView.layer.transform = CATransform3DMakeScale(0.7142f, 0.7142f, 1.f);
    [transitionContext completeTransition:YES];
    [self animateView:imageView
       verticalOffset:-10.f
     horizontalOffset:10.f
            transform:CATransform3DMakeScale(0.5f, 0.5f, 1.f)
      otherAnimations:^{
          toViewController.view.layer.transform = CATransform3DIdentity;
      }
           completion:^{
               [imageView.layer removeFromSuperlayer];
           }];
}

- (void)animateView:(UIView*)view verticalOffset:(CGFloat)verticalOffset horizontalOffset:(CGFloat)horizontalOffset
          transform:(CATransform3D)transform otherAnimations:(void(^)())animations completion:(void(^)())completion
{
    [UIView animateWithDuration:[self transitionDuration:nil] animations:^{
        if (animations)
            animations();
        view.layer.transform = transform;
        CGRect frame = view.frame;
        frame.origin.y += verticalOffset;
        frame.origin.x += horizontalOffset;
        view.frame = frame;
        view.alpha = 0;
    } completion:^(BOOL finished) {
        if (completion)
            completion();
        view.alpha = 1;
        view.layer.transform = CATransform3DIdentity;
    }];
}

@end
