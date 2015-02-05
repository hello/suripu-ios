//
//  HEMSleepSummaryPointerGradientView.m
//  Sense
//
//  Created by Delisa Mason on 1/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMSleepSummaryPointerGradientView.h"

@interface HEMSleepSummaryPointerGradientView ()
@property (nonatomic, strong) CAGradientLayer* leftGradientLayer;
@property (nonatomic, strong) CAGradientLayer* rightGradientLayer;
@end

@implementation HEMSleepSummaryPointerGradientView

static CGFloat const HEMSummaryPointerWidth = 7.5f;
static CGFloat const HEMSummaryPointerHeight = 8.f;
static CGFloat const HEMSummaryPointerColors[] = { 1.f, 1.f, 0.97f, 1.f };

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self configureGradientLayers];
}

- (void)configureGradientLayers
{
    if (!self.leftGradientLayer) {
        UIColor* leftColor = [UIColor whiteColor];
        UIColor* rightColor = [UIColor colorWithWhite:1.f alpha:0];
        self.leftGradientLayer = [CAGradientLayer layer];
        self.leftGradientLayer.colors = @[(id)leftColor.CGColor, (id)rightColor.CGColor];
        self.leftGradientLayer.locations = @[@0, @1];
        self.leftGradientLayer.startPoint = CGPointZero;
        self.leftGradientLayer.endPoint = CGPointMake(1, 0);
        [self.layer insertSublayer:self.leftGradientLayer atIndex:0];
    }
    if (!self.rightGradientLayer) {
        UIColor* rightColor = [UIColor whiteColor];
        UIColor* leftColor = [UIColor colorWithWhite:1.f alpha:0];
        self.rightGradientLayer = [CAGradientLayer layer];
        self.rightGradientLayer.colors = @[(id)leftColor.CGColor, (id)rightColor.CGColor];
        self.rightGradientLayer.locations = @[@0, @1];
        self.rightGradientLayer.startPoint = CGPointZero;
        self.rightGradientLayer.endPoint = CGPointMake(1, 0);
        [self.layer insertSublayer:self.rightGradientLayer atIndex:0];
    }
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    self.leftGradientLayer.frame = CGRectMake(0, 0, self.pointerXOffset - HEMSummaryPointerWidth, height);
    self.rightGradientLayer.frame = CGRectMake(self.pointerXOffset + HEMSummaryPointerWidth, 0, width - self.pointerXOffset, height);
}

- (void)drawRect:(CGRect)rect
{
    [self drawGradientInRect:rect];
}

- (void)drawGradientInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPathRef path = [self newPathForRect:rect];

    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGPathRelease(path);
    CGContextClip(ctx);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, HEMSummaryPointerColors, NULL, 2);
    CGColorSpaceRelease(colorSpace);

    CGFloat startXOffset = CGRectGetMinX(rect);
    CGFloat endXOffset = CGRectGetMaxX(rect);
    CGFloat startYOffset = CGRectGetMinY(rect);
    CGFloat endYOffset = CGRectGetMaxY(rect) - HEMSummaryPointerHeight;
    CGPoint gradientStart = CGPointMake(startXOffset, startYOffset);
    CGPoint gradientEnd   = CGPointMake(startXOffset,  CGRectGetMaxY(rect));
    CGFloat pointerXOffset = MAX(0, self.pointerXOffset - HEMSummaryPointerWidth);

    CGContextDrawLinearGradient(ctx, gradient, gradientStart, gradientEnd, 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, startXOffset, endYOffset);
    CGContextSetLineWidth(ctx, 0.5f);
    CGContextAddLineToPoint(ctx, pointerXOffset, endYOffset);
    CGContextAddLineToPoint(ctx, pointerXOffset + HEMSummaryPointerWidth, endYOffset + HEMSummaryPointerHeight);
    CGContextAddLineToPoint(ctx, pointerXOffset + HEMSummaryPointerWidth*2, endYOffset);
    CGContextAddLineToPoint(ctx, endXOffset, endYOffset);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor blackColor] colorWithAlphaComponent:0.05].CGColor);
    CGContextStrokePath(ctx);
}

- (CGPathRef)newPathForRect:(CGRect)rect
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat startXOffset = CGRectGetMinX(rect);
    CGFloat endXOffset = CGRectGetMaxX(rect);
    CGFloat startYOffset = CGRectGetMinY(rect);
    CGFloat endYOffset = CGRectGetMaxY(rect) - HEMSummaryPointerHeight;
    CGFloat pointerXOffset = MAX(0, self.pointerXOffset - HEMSummaryPointerWidth);
    CGPathMoveToPoint(path, NULL, startXOffset, startYOffset);
    CGPathAddLineToPoint(path, NULL, endXOffset, startYOffset);
    CGPathAddLineToPoint(path, NULL, endXOffset, endYOffset);
    CGPathAddLineToPoint(path, NULL, pointerXOffset + HEMSummaryPointerWidth*2, endYOffset);
    CGPathAddLineToPoint(path, NULL, pointerXOffset + HEMSummaryPointerWidth, endYOffset + HEMSummaryPointerHeight);
    CGPathAddLineToPoint(path, NULL, pointerXOffset, endYOffset);
    CGPathAddLineToPoint(path, NULL, startXOffset, endYOffset);
    CGPathAddLineToPoint(path, NULL, startXOffset, startYOffset);
    return path;
}

- (void)setPointerXOffset:(CGFloat)pointerXOffset
{
    if (pointerXOffset == _pointerXOffset)
        return;

    _pointerXOffset = pointerXOffset;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

@end
