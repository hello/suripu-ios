//
//  HEMTransitionDelegate.h
//  Sense
//
//  Created by Jimmy Lu on 2/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMTransitionDelegate : NSObject <
    UIViewControllerAnimatedTransitioning,
    UIViewControllerTransitioningDelegate
>

extern CGFloat const HEMTransitionDimmingViewMaxAlpha;

@property (nonatomic, assign) CGFloat duration;

/**
 * @method animatePresentationWithContext:
 *
 * @discussion
 * Subclasses should override this method as this is called when the controller
 * is being presented.  There is no need to additionally handle the delegate
 * callbacks
 */
- (void)animatePresentationWithContext:(id<UIViewControllerContextTransitioning>)context;

/**
 * @method animateDismissalWithContext:
 *
 * @discussion
 * Subclasses should override this method as this is called when the controller
 * is being dismissed.  There is no need to additionally handle the delegate
 * callbacks
 */
- (void)animateDismissalWithContext:(id<UIViewControllerContextTransitioning>)context;

/**
 * @discussion
 * Convenience method to obtain a "dimming view" that can be used as a transparent
 * background view while the transition takes place.  Caller must add the view
 * directly the container as needed.  The dimming view will be returned with 0 alpha
 *
 * @param the context: the transitioning context
 * @return the dimming view
 */
- (UIView*)dimmingViewWithContext:(id<UIViewControllerContextTransitioning>)context;

/**
 * @discussion
 * Convenience method to show / hide the status bar when transitioning between
 * controllers
 *
 * @param show: YES to show the status bar, NO otherwise
 */
- (void)showStatusBar:(BOOL)show;

/**
 * @discussion
 * Convenience method to determine if status bar is currently showing
 *
 * @return YES if the status bar is currently showing.  NO otherwise
 */
- (BOOL)isStatusBarShowing;

@end

NS_ASSUME_NONNULL_END
