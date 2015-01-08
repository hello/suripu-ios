//
//  HEMPresleepItemCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMPresleepItemCollectionViewCell.h"
#import "HelloStyleKit.h"

@interface HEMPresleepItemCollectionViewCell ()
@property (nonatomic, strong) CAGradientLayer* gradientLayer;
@end

@implementation HEMPresleepItemCollectionViewCell

static CGFloat const HEMPresleepItemBorderWidth = 1.f;
static CGFloat const HEMBorderDashLength[] = {4,4};
static int const HEMBorderDashLengthCount = 2;

- (void)awakeFromNib
{
    self.typeImageView.layer.borderWidth = 1.f;
    self.typeImageView.layer.cornerRadius = CGRectGetWidth(self.typeImageView.bounds) / 2;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.gradientLayer) {
        UIColor* topColor = [HelloStyleKit timelineGradientDarkColor];
        UIColor* bottomColor = [UIColor whiteColor];
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    CGRect gradientRect = self.bounds;
    gradientRect.size.height -= HEMPresleepItemBorderWidth * 2;
    gradientRect.origin.y += HEMPresleepItemBorderWidth;
    self.gradientLayer.frame = gradientRect;
}

- (void)drawRect:(CGRect)rect
{
    [self drawBordersInRect:rect];
}

- (void)drawBordersInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect shadowRect = rect;
    shadowRect.size.height = HEMPresleepItemBorderWidth;
    CGColorRef color = [HelloStyleKit timelineSectionBorderColor].CGColor;
    CGContextSetFillColorWithColor(ctx, color);
    CGContextSetStrokeColorWithColor(ctx, color);
    CGContextSetLineWidth(ctx, HEMPresleepItemBorderWidth);
    CGContextFillRect(ctx, shadowRect);

    CGContextSetLineDash(ctx, 0, HEMBorderDashLength, HEMBorderDashLengthCount);
    CGFloat y = CGRectGetHeight(rect) - HEMPresleepItemBorderWidth;
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), y);
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), y);
    CGContextStrokePath(ctx);
}

@end
