//
//  HEMSleepScoreLoadingView.m
//  Sense
//
//  Created by Delisa Mason on 6/24/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMSleepScoreLoadingView.h"
#import "HelloStyleKit.h"

@implementation HEMSleepScoreLoadingView

- (void)awakeFromNib {
    self.layer.opacity = 0;
}

- (void)setLoading:(BOOL)loading {
    NSString *const scoreLoadingAnimation = @"scoreLoadingAnimation";
    if (loading) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(opacity))];
        animation.autoreverses = YES;
        animation.repeatDuration = HUGE_VALF;
        animation.duration = 0.65f;
        animation.fromValue = @0;
        animation.toValue = @1;
        [self.layer addAnimation:animation forKey:scoreLoadingAnimation];
    } else {
        [self.layer removeAnimationForKey:scoreLoadingAnimation];
        [UIView animateWithDuration:0.2f
                         animations:^{
                           self.layer.opacity = 0;
                         }];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// background oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 1, 3);
    CGContextRotateCTM(context, -90 * M_PI / 180);

    CGRect backgroundOvalRect = CGRectMake(-155, 0, 155, 155);
    UIBezierPath *backgroundOvalPath = UIBezierPath.bezierPath;
    [backgroundOvalPath
        addArcWithCenter:CGPointMake(CGRectGetMidX(backgroundOvalRect), CGRectGetMidY(backgroundOvalRect))
                  radius:CGRectGetWidth(backgroundOvalRect) / 2
              startAngle:-129 * M_PI / 180
                endAngle:129 * M_PI / 180
               clockwise:YES];

    [HelloStyleKit.tintColor setStroke];
    backgroundOvalPath.lineWidth = 1;
    [backgroundOvalPath stroke];

    CGContextRestoreGState(context);
}

@end
