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
    [self drawCaretInRect:rect];
}

- (void)drawRoundedContainerInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect containerRect = CGRectMake(CGRectGetMinX(rect) + HEMEventInfoViewCaretDepth + HEMEventInfoViewCaretInset, CGRectGetMinY(rect), CGRectGetWidth(rect) - HEMEventInfoViewCaretDepth - HEMEventInfoViewCaretInset, CGRectGetHeight(rect));
    for (int i = 5; i >= 0; i--) {
        UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(containerRect, i, i) cornerRadius:HEMEventInfoViewCornerRadius];
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:100 - (i * 4)alpha:0.8f].CGColor);
        [bezierPath fill];
    }
}

- (void)drawCaretInRect:(CGRect)rect
{
    CGFloat caretYOffset = [self yOffsetForCaretPointInRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect) + HEMEventInfoViewCaretInset, caretYOffset);
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect) + HEMEventInfoViewCaretRadius + HEMEventInfoViewCaretInset, caretYOffset - HEMEventInfoViewCaretRadius);
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect) + HEMEventInfoViewCaretRadius + HEMEventInfoViewCaretInset, caretYOffset + HEMEventInfoViewCaretRadius);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
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
