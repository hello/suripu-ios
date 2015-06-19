//
//  HEMGradientCollectionView.m
//  Sense
//
//  Created by Delisa Mason on 5/20/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMGradientCollectionView.h"
#import "HelloStyleKit.h"

@implementation HEMGradientCollectionView

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(ctx, [HelloStyleKit timelineGradient].CGGradient, CGPointMake(CGRectGetMaxX(rect), 0), CGPointZero, 0);
}

@end
