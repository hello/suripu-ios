//
//  HEMEventInfoView.m
//  Sense
//
//  Created by Delisa Mason on 10/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMEventInfoView.h"
#import "HEMPaddedRoundedLabel.h"

@implementation HEMEventInfoView

static CGFloat const HEMEventInfoViewCaretRadius = 8.f;
static CGFloat const HEMEventInfoViewCaretInset = 5.f;
static CGFloat const HEMEventInfoViewCaretDepth = 6.f;
static CGFloat const HEMEventInfoViewCaretYOffset = 10.f;
static CGFloat const HEMEventInfoViewCornerRadius = 4.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.caretPosition = HEMEventInfoViewCaretPositionTop;
}

- (void)drawRect:(CGRect)rect
{
    [self drawRoundedContainerInRect:rect];
//    [self drawCaretInRect:rect];
}

- (void)drawRoundedContainerInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect containerRect = CGRectMake(CGRectGetMinX(rect) + HEMEventInfoViewCaretDepth + HEMEventInfoViewCaretInset, CGRectGetMinY(rect), CGRectGetWidth(rect) - HEMEventInfoViewCaretDepth - HEMEventInfoViewCaretInset, CGRectGetHeight(rect));
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:containerRect cornerRadius:HEMEventInfoViewCornerRadius + 1];
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.05f].CGColor);
    [bezierPath fill];

    CGFloat caretYOffset = [self yOffsetForCaretPointInRect:rect];
    CGRect caretRect = CGRectMake(
                                  CGRectGetMinX(rect) + HEMEventInfoViewCaretInset,
                                  caretYOffset - HEMEventInfoViewCaretRadius,
                                  HEMEventInfoViewCaretRadius,
                                  HEMEventInfoViewCaretRadius * 2.2);
    [self drawCaretInRect:caretRect];


    bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(containerRect, 1, 1) cornerRadius:HEMEventInfoViewCornerRadius];
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.f alpha:1.f].CGColor);
    [bezierPath fill];
    caretRect.origin.x += 1;
    [self drawCaretInRect:caretRect];
}

- (void)drawCaretInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);

    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));

    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

- (CGFloat)yOffsetForCaretPointInRect:(CGRect)rect
{
    switch (self.caretPosition) {
    case HEMEventInfoViewCaretPositionMiddle:
        return CGRectGetMidY(rect);
    case HEMEventInfoViewCaretPositionBottom:
        return CGRectGetMaxY(rect) - HEMEventInfoViewCaretYOffset - HEMEventInfoViewCaretRadius;
    case HEMEventInfoViewCaretPositionTop:
    default:
        return HEMEventInfoViewCaretYOffset + HEMEventInfoViewCaretRadius;
    }
}

@end
