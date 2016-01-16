//
//  HEMModalTransitionDelegate.m
//  Sense
//
//  Created by Jimmy Lu on 10/26/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMSimpleModalTransitionDelegate.h"
#import "HEMActivityCoverView.h"
#import "HEMActivityIndicatorView.h"

static CGFloat HEMSimpleModalDismissViewEndScale = 0.7f;
static CGFloat HEMSimpleModalDismissMessageEndDelay = 0.8f;

@interface HEMSimpleModalTransitionDelegate()

@property (nonatomic, assign) UIWindowLevel originalWindowLevel;
@property (nonatomic, assign) BOOL previouslyShowingStatusBar;

@end

@implementation HEMSimpleModalTransitionDelegate

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

#pragma mark - Status Bar

- (void)saveAndUpdateStatusBarAppearance {
    [self setPreviouslyShowingStatusBar:[self isStatusBarShowing]];
    
    if ([self wantsStatusBar] != [self previouslyShowingStatusBar]) {
        [self showStatusBar:[self wantsStatusBar]];
    }
}

- (void)restoreStatusBarAppearance {
    [self showStatusBar:[self previouslyShowingStatusBar]];
}

#pragma mark - Transition styles

- (void)presentNormallyWithContext:(id<UIViewControllerContextTransitioning>)context
                       inContainer:(UIView*)containerView
                              from:(UIViewController*)fromController
                                to:(UIViewController*)toController {
    
    CGRect containerBounds = [containerView bounds];
    
    UIView* dimmingView = [self dimmingViewWithContext:context];
    [containerView addSubview:dimmingView];
    
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
                         [[self dimmingViewWithContext:context] setAlpha:HEMTransitionDimmingViewMaxAlpha];
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
    
    __weak typeof(self) weakSelf = self;
    void(^dismiss)(void) = ^{
        CGRect updateFrame = [fromView frame];
        updateFrame.origin.y = CGRectGetHeight([containerView bounds]);
        
        [UIView animateWithDuration:[weakSelf duration]
                         animations:^{
                             [fromView setFrame:updateFrame];
                             [[weakSelf dimmingViewWithContext:context] setAlpha:0.0f];
                         }
                         completion:^(BOOL finished) {
                             [fromView removeFromSuperview];
                             [context completeTransition:finished];
                             completion ();
                         }];
    };
    
    if ([self dismissMessage]) {
        [self showEndMessageIn:fromView completion:dismiss];
    } else {
        dismiss ();
    }

}

- (void)showEndMessageIn:(UIView*)fromView completion:(void(^)(void))completion {
    UIView* whiteBg = [[UIView alloc] initWithFrame:[fromView bounds]];
    [whiteBg setBackgroundColor:[UIColor whiteColor]];
    
    UIView* snapshot = [fromView snapshotViewAfterScreenUpdates:NO];
    
    [whiteBg addSubview:snapshot];
    [fromView addSubview:whiteBg];
    
    [UIView animateWithDuration:[self duration]
                     animations:^{
                         CGFloat scale = HEMSimpleModalDismissViewEndScale;
                         [[snapshot layer] setTransform:CATransform3DMakeScale(scale, scale, scale)];
                         [[snapshot layer] setOpacity:0.0f];
                     }
                     completion:^(BOOL finished) {
                         HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] initWithFrame:[whiteBg bounds]];
                         [[activityView activityLabel] setText:[self dismissMessage]];
                         [[activityView indicator] setHidden:YES];
                         [whiteBg addSubview:activityView];
                         
                         [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                             int64_t delayInSeconds = (int64_t) (HEMSimpleModalDismissMessageEndDelay * NSEC_PER_SEC);
                             dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds);
                             dispatch_after(delay, dispatch_get_main_queue(), completion);
                         }];
                     }];
}

@end
