//
//  HEMMotionHintView.m
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMHintGestureView.h"
#import "HelloStyleKit.h"

static CGFloat const HEMGestureHintBorderWidth = 2.0f;
static CGFloat const HEMGestureAnimationDuration = 0.75f;

@interface HEMHintGestureView()

@property (nonatomic, assign) CGPoint startingCenter;
@property (nonatomic, assign) CGPoint endingCenter;
@property (nonatomic, assign, getter=shouldStopAnimation) BOOL stopAnimation;

@end

@implementation HEMHintGestureView

- (instancetype)initWithFrame:(CGRect)frame withEndCenter:(CGPoint)endCenter {
    self = [super initWithFrame:frame];
    if (self) {
        _endingCenter = endCenter;
        _startingCenter = [self center];
        [self configureView];
    }
    return self;
}

- (void)configureView {
    [self setAlpha:0.0f];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    // draw inner circle
    CGRect circleFrame = CGRectInset(rect, HEMGestureHintBorderWidth, HEMGestureHintBorderWidth);
    CGColorRef innerColorRef = [[HelloStyleKit handholdingGestureHintColor] CGColor];
    CGContextSetFillColorWithColor(ctx, innerColorRef);
    CGContextFillEllipseInRect(ctx, circleFrame);
    
    // draw the circle's border
    CGColorRef borderColorRef = [[HelloStyleKit handholdingGestureHintBorderColor] CGColor];
    CGContextSetStrokeColorWithColor(ctx, borderColorRef);
    CGContextSetLineWidth(ctx, HEMGestureHintBorderWidth);
    CGContextStrokeEllipseInRect(ctx, circleFrame);
    
    CGContextRestoreGState(ctx);
}

- (void)animate:(void(^)(void))animation completion:(void(^)(BOOL finished))completion {
    if ([self shouldStopAnimation]) {
        if (completion) {
            completion (YES);
        }
        return;
    }
    [UIView animateWithDuration:HEMGestureAnimationDuration
                     animations:animation
                     completion:completion];
}

- (void)fade:(CGFloat)alpha then:(void(^)(BOOL finished))completion {
    [self animate:^{
        [self setAlpha:alpha];
    } completion:completion];
}

- (void)move:(CGPoint)centerPoint then:(void(^)(BOOL finished))completion {
    [self animate:^{
        [self setCenter:centerPoint];
    } completion:completion];
}

- (void)startAnimation {
    [self setCenter:[self startingCenter]];
    [self setStopAnimation:NO];
    [self setHidden:NO];
    
    [self fade:1.0f then:^(BOOL finished) {
        [self move:[self endingCenter] then:^(BOOL finished) {
            [self fade:0.0f then:^(BOOL finished) {
                [self startAnimation];
            }];
        }];
    }];
}

- (void)endAnimation {
    [self setStopAnimation:YES];
    [self setHidden:YES];
    [self setAlpha:0.0f];
}

@end
