//
//  HEMTimelineDrawingUtils.m
//  Sense
//
//  Created by Delisa Mason on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMTimelineDrawingUtils.h"

@implementation HEMTimelineDrawingUtils

+ (void)drawVerticalGradientInRect:(CGRect)rect withColors:(CGFloat[])colors
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;

    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, rect);
    CGContextClip(ctx);

    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));

    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;

    CGContextRestoreGState(ctx);
}
@end
