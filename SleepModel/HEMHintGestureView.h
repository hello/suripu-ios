//
//  HEMMotionHintView.h
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMHintGestureView : UIView

- (instancetype)initWithFrame:(CGRect)frame withEndCenter:(CGPoint)endCenter;
- (void)startAnimation;
- (void)endAnimation;

@end
