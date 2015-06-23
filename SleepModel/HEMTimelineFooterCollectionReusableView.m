//
//  HEMTimelineFooterCollectionReusableView.m
//  Sense
//
//  Created by Delisa Mason on 1/8/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMTimelineFooterCollectionReusableView.h"
#import "HelloStyleKit.h"

@implementation HEMTimelineFooterCollectionReusableView

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(ctx, [HelloStyleKit timelineGradient].CGGradient, CGPointMake(CGRectGetMaxX(rect), 0),
                                CGPointZero, 0);
}

@end
