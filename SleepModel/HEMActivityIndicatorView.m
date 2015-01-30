//
//  HEMActivityIndicatorView.m
//  Sense
//
//  Created by Jimmy Lu on 11/26/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMActivityIndicatorView.h"
#import "HelloStyleKit.h"
#import "HEMMathUtil.h"

static NSString* const HEMActivityIndicatorRotateKey = @"rotate";
static CGFloat const HEMActivityIndicatorAnimDuration = 1.0f;

@interface HEMActivityIndicatorView()

@property (nonatomic, strong) CALayer* indicatorLayer;

@end

@implementation HEMActivityIndicatorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImageView* indicator = [[UIImageView alloc] initWithImage:[HelloStyleKit loading]];
    [indicator setContentMode:UIViewContentModeScaleAspectFill];
    [indicator setBackgroundColor:[UIColor clearColor]];
    [indicator setFrame:[self bounds]];

    CALayer* layer = [indicator layer];
    [self setIndicatorLayer:layer];
    [[self layer] addSublayer:layer];
}

- (void)start {
    [[self layer] addSublayer:[self indicatorLayer]];
    
    if ([[self indicatorLayer] animationForKey:HEMActivityIndicatorRotateKey] == nil) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.toValue = @(HEMDegreesToRadians(360.0f));
        animation.duration = HEMActivityIndicatorAnimDuration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [[self indicatorLayer] addAnimation:animation forKey:HEMActivityIndicatorRotateKey];
    }
}

- (void)stop {
    [[self indicatorLayer] removeAnimationForKey:HEMActivityIndicatorRotateKey];
    [[self indicatorLayer] removeFromSuperlayer];
}


@end
