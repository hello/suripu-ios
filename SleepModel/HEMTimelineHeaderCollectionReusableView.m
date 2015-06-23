//
//  HEMTimelineHeaderCollectionReusableView.m
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMTimelineHeaderCollectionReusableView.h"
#import "HelloStyleKit.h"

@interface HEMTimelineHeaderCollectionReusableView ()
@end

@implementation HEMTimelineHeaderCollectionReusableView

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(ctx, [HelloStyleKit timelineGradient].CGGradient, CGPointMake(CGRectGetMaxX(rect), 0), CGPointZero, 0);
}

@end
