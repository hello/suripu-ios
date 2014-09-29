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

@end
