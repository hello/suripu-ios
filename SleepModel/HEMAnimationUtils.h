//
//  HEMAnimationUtils.h
//  Sense
//
//  Created by Jimmy Lu on 9/29/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMAnimationUtils : NSObject

/**
 * Animate the drawing of a second border within the view using the same color
 * as original border color.  This animation automatically repeats after completion.
 * To remove the animation, simply remove the layer returned from it's super layer.
 *
 * @param view:   the view to animate around
 * @return layer: the layer that the animation resides in
 */
+ (CALayer*)animateActivityAround:(UIView*)view;

/**
 * Convenience method to wrap a group of animation in a transaction so that a final
 * completion block can be called and animations appear more "in sync"
 *
 * @param animation:          the block containing animations.  Be sure to use
 *                            UIViewAnimationOptionOverrideInheritedCurve to synchronize
 *                            on the timing function across multiple animation blocks
 *
 * @param completion:         the block to call when all animations are complete
 *
 * @param timingFunctionName: the native function name to use.  
 *                            ex: kCAMediaTimingFunctionEaseOut
 */
+ (void)transactAnimation:(void(^)(void))animation
               completion:(void(^)(void))completion
                   timing:(NSString*)timingFunctionName;

/**
 * Start the view in a shrunken state, grow it passed it's normal scale, then finish
 * at it's normal state
 * @param view:       the view to grow
 * @param completion: the block to call when all is done
 */
+ (void)grow:(UIView*)view completion:(void(^)(BOOL finished))completion;

/**
 * Fade the view out, make a callback when it's not visible, then fade it back in
 * after the operation is done and call the inBlock
 *
 * @param view: view to animate
 * @param outBlock: the block to call when view is temporarily not visible
 * @param inBlock: the block to call when view is once again visible
 */
+ (void)fade:(UIView*)view out:(void(^)(void))outBlock thenIn:(void(^)(void))inBlock;

@end
