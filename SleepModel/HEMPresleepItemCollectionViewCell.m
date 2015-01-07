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
    gradientRect.size.height -= HEMPresleepItemBorderWidth;
    gradientRect.origin.y += HEMPresleepItemBorderWidth;
    self.gradientLayer.frame = gradientRect;
}

- (void)drawRect:(CGRect)rect
{
    [self drawTopBorderInRect:rect];
}

- (void)drawTopBorderInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGRect shadowRect = rect;
    shadowRect.size.height = HEMPresleepItemBorderWidth;
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit timelineSectionBorderColor].CGColor);
    CGContextFillRect(ctx, shadowRect);
}

@end
