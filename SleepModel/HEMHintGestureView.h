//
//  HEMMotionHintView.h
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMHintGestureView : UIView

/**
 * Initialize an instance of the gesture hint.  This is intended to be used with
 * HEMHandholdingView.
 *
 * @param frame: the frame for the gesture.  Frame determines the starting center
 * @param endCenter: the center point for which this view will end at when the
 *                   animation ends
 */
- (instancetype)initWithFrame:(CGRect)frame withEndCenter:(CGPoint)endCenter;

/**
 * Begin auto-reversed animation of the gesture
 */
- (void)startAnimation;

/**
 * Stop the animation
 */
- (void)endAnimation;

@end
