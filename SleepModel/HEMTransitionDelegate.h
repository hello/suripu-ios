//
//  HEMTransitionDelegate.h
//  Sense
//
//  Created by Jimmy Lu on 2/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMTransitionDelegate : NSObject <
    UIViewControllerAnimatedTransitioning,
    UIViewControllerTransitioningDelegate
>

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

@end
