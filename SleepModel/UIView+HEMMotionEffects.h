//
//  UIView+HEMMotionEffects.h
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMMotionEffectsDirection) {
    HEMMotionEffectsDirectionHorizontal = 1 << 2,
    HEMMotionEffectsDirectionVertical = 1 << 3,
};

@interface UIView (HEMMotionEffects)

/**
 * This uses iOS 7's UIInterpolatingMotionEffect to create the 3D parallax-
 * like effect you see on your home screen on the phone where the background
 * image moves as you move your phone
 *
 * @param border: the amount of space around the view that can be moved
 */
- (void)add3DEffectWithBorder:(CGFloat)border;

- (void)add3DEffectWithBorder:(CGFloat)border direction:(HEMMotionEffectsDirection)direction;

@end
