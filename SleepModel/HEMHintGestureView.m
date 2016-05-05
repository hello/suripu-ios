//
//  HEMMotionHintView.m
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMHintGestureView.h"
#import "UIColor+HEMStyle.h"

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
    UIColor* blue = [UIColor blue6];
    UIColor* innerColor = [blue colorWithAlphaComponent:0.3f];
    CGColorRef innerColorRef = [innerColor CGColor];
    CGContextSetFillColorWithColor(ctx, innerColorRef);
    CGContextFillEllipseInRect(ctx, circleFrame);
    
    // draw the circle's border
    UIColor* borderColor = [blue colorWithAlphaComponent:0.8f];
    CGColorRef borderColorRef = [borderColor CGColor];
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
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animation
                     completion:completion];
}

- (void)fade:(CGFloat)alpha then:(void(^)(BOOL finished))completion {
    __weak typeof(self) weakSelf = self;
    [self animate:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setAlpha:alpha];
    } completion:completion];
}

- (void)move:(CGPoint)centerPoint then:(void(^)(BOOL finished))completion {
    __weak typeof(self) weakSelf = self;
    [self animate:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setCenter:centerPoint];
    } completion:completion];
}

- (void)scale:(CGFloat)scale then:(void(^)(BOOL finished))completion {
    __weak typeof(self) weakSelf = self;
    [self animate:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setTransform:CGAffineTransformMakeScale(scale, scale)];
    } completion:completion];
}

- (void)startAnimation {
    switch ([self animation]) {
        case HEMHintGestureAnimationStatic:
            [self justShowIt];
            break;
        case HEMHintGestureAnimationPulsate:
            [self pulsate];
            break;
        default:
            [self translate];
            break;
    }
}

- (void)endAnimation {
    [self fade:0.0f then:^(BOOL finished) {
        [self setStopAnimation:YES];
        [self setHidden:YES];
    }];
}

#pragma mark - Animation Types

- (void)translate {
    [self setCenter:[self startingCenter]];
    [self setStopAnimation:NO];
    [self setHidden:NO];
    
    [self fade:1.0f then:^(BOOL finished) {
        [self move:[self endingCenter] then:^(BOOL finished) {
            [self fade:0.0f then:^(BOOL finished) {
                if (![self shouldStopAnimation]) {
                    [self translate];
                }
            }];
        }];
    }];
}

- (void)justShowIt {
    [self setCenter:[self startingCenter]];
    [self setStopAnimation:NO];
    [self setHidden:NO];
    [self fade:1.0f then:nil];
}

- (void)pulsate {
    [self setCenter:[self startingCenter]];
    [self setStopAnimation:NO];
    [self setHidden:NO];
    [self fade:1.0f then:^(BOOL finished) {
        [self scale:0.6f then:^(BOOL finished) {
            [self scale:1.1f then:^(BOOL finished) {
                if (![self shouldStopAnimation]) {
                    [self pulsate];
                }
            }];
        }];
    }];

}

@end
