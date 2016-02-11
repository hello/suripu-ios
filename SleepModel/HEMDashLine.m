//
//  HEMDashLine.m
//  Sense
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMDashLine.h"

static CGFloat const HEMDashLineDefaultWidth = 1.0f;

@implementation HEMDashLine

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _lineWidth = HEMDashLineDefaultWidth;
        _dashColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, [self lineWidth]);
    CGContextSetStrokeColorWithColor(context, [[self dashColor] CGColor]);
    
    CGFloat dash = [self lineWidth] * 2.0f;
    CGFloat dashes[2] = {dash, dash};
    CGContextSetLineDash(context, 0.0f, dashes, 2);
    
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
}

@end
