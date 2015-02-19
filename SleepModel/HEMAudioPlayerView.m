//
//  HEMAudioPlayerView.m
//  Sense
//
//  Created by Delisa Mason on 2/19/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMAudioPlayerView.h"
#import "HelloStyleKit.h"

@implementation HEMAudioPlayerView

- (void)drawRect:(CGRect)rect {
    CGRect fillRect = CGRectInset(rect, 2, 2);
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:floorf(CGRectGetHeight(rect)/2)];
    [[[HelloStyleKit tintColor] colorWithAlphaComponent:0.1] setFill];
    [[[HelloStyleKit tintColor] colorWithAlphaComponent:0.3] setStroke];
    [path fill];
    [path stroke];
}

@end
