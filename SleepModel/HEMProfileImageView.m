//
//  HEMProfileImageView.m
//  Sense
//
//  Created by Jimmy Lu on 5/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMProfileImageView.h"

@implementation HEMProfileImageView

- (void)awakeFromNib {
    [self applyCircleMask];
}

- (void)applyCircleMask {
    CGFloat radius = CGRectGetHeight([self bounds]) / 2.0f;
    UIBezierPath* rectPath = [UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:0.0f];
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:radius];
    [rectPath appendPath:circlePath];
    [rectPath setUsesEvenOddFillRule:YES];
    
    CAShapeLayer* mask = [CAShapeLayer layer];
    [mask setPath:[rectPath CGPath]];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor whiteColor] CGColor]];
    [[self layer] addSublayer:mask];
    
    [self setClipsToBounds:YES];
}

- (void)clearPhoto {
    [self setImageWithURL:nil];
    [self setImage:[UIImage imageNamed:@"defaultAvatar"]];
}

@end
