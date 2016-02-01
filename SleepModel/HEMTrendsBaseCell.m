//
//  HEMTrendsBaseCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBaseCell.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsBaseCellTitleDividerYOffset = 48.0f;
static CGFloat const HEMTrendsBaseCellTitleDividerHeight = 1.0f;

@implementation HEMTrendsBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self titleLabel] setFont:[UIFont trendsTitleFont]];
    [[self titleLabel] setTextColor:[UIColor trendsTitleColor]];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIColor* lineColor = [UIColor trendsTitleDividerColor];
    
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    CGContextSetLineWidth(context, HEMTrendsBaseCellTitleDividerHeight);
    
    CGFloat y = HEMTrendsBaseCellTitleDividerYOffset;
    CGContextMoveToPoint(context, 0.0f, y);
    CGContextAddLineToPoint(context, CGRectGetWidth([self bounds]), y);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

@end
