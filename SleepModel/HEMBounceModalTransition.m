//
//  HEMBounceTransitionDelegate.m
//  Sense
//
//  Created by Jimmy Lu on 2/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMBounceModalTransition.h"
#import "HEMActivityCoverView.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const HEMBounceDefaultDamping = 0.8f;
static CGFloat const HEMBounceEndScale = 0.7f;

@implementation HEMBounceModalTransition

- (instancetype)initWithEndMessage:(NSString *)message andBounceDamping:(CGFloat)bounceDamping {
    self = [super init];
    if (self) {
        _bounceDamping = bounceDamping;
        _message = [message copy];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _bounceDamping = HEMBounceDefaultDamping;
    }
    return self;
}

- (void)animatePresentationWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIViewController* toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect initialFrame = [[toVC view] frame];
    initialFrame.origin.y = CGRectGetHeight([[context containerView] bounds]);
    [[toVC view] setFrame:initialFrame];
    
    [[context containerView] addSubview:[toVC view]];
    
    [UIView animateWithDuration:[self duration]
                          delay:0.0f
         usingSpringWithDamping:[self bounceDamping]
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // adjust for the status bar to prevent odd jump of the navigation bar, if
                         // one is used, when animation completes
                         CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
                         CGFloat statusHeight = CGRectGetHeight(statusBarFrame);
                         CGRect finalFrame = [[toVC view] frame];
                         finalFrame.origin.y = statusHeight;
                         finalFrame.size.height -= statusHeight;
                         [[toVC view] setFrame:finalFrame];
                     }
                     completion:^(BOOL finished) {
                         [context completeTransition:YES];
                     }];
}

- (void)animateDismissalWithContext:(id<UIViewControllerContextTransitioning>)context {
    UIViewController* fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    void(^dismiss)(void) = ^{
        [UIView animateWithDuration:[self duration] * [self bounceDamping]
                         animations:^{
                             CGRect frame = [[fromVC view] frame];
                             frame.origin.y = CGRectGetHeight(frame);
                             [[fromVC view] setFrame:frame];
                         }
                         completion:^(BOOL finished) {
                             [[fromVC view] removeFromSuperview];
                             [context completeTransition:YES];
                         }];
    };
    
    if ([[self message] length] > 0) {
        [self showEndMessageIn:[fromVC view] completion:dismiss];
    } else {
        dismiss();
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
                         [[snapshot layer] setTransform:CATransform3DMakeScale(HEMBounceEndScale,
                                                                               HEMBounceEndScale,
                                                                               HEMBounceEndScale)];
                         [[snapshot layer] setOpacity:0.0f];
                     }
                     completion:^(BOOL finished) {
                         HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] initWithFrame:[whiteBg bounds]];
                         [[activityView activityLabel] setText:[self message]];
                         [[activityView indicator] setHidden:YES];
                         [whiteBg addSubview:activityView];
                         
                         [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                             NSTimeInterval delayInSeconds = 1.0f;
                             dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(delay, dispatch_get_main_queue(), completion);
                         }];
                     }];
}

@end
