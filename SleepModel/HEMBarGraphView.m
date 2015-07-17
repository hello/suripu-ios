//
//  HEMBarGraphView.m
//  Sense
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENTrend.h>
#import "HEMBarGraphView.h"
#import "UIColor+HEMStyle.h"

@implementation HEMBarGraphView

- (void)setValues:(NSArray*)values
{
    if ([_values isEqual:values])
        return;
    _values = values;
    [self layoutBars];
}

- (void)layoutBars
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.values.count == 0)
        return;
    NSArray* sortedValues = [[self.values valueForKey:NSStringFromSelector(@selector(yValue))]
        sortedArrayUsingSelector:@selector(compare:)];
    CGFloat max = [[sortedValues lastObject] floatValue] * 1.25;
    CGFloat min = [[sortedValues firstObject] floatValue] * 0.5;
    CGFloat barWidth = CGRectGetWidth(self.bounds) / self.values.count;
    CGFloat fullHeight = CGRectGetHeight(self.bounds);
    for (int i = 0; i < self.values.count; i++) {
        SENTrendDataPoint* point = self.values[i];
        CGFloat barHeight;
        if (max == min)
            barHeight = 0;
        else
            barHeight = fullHeight * ((point.yValue - min) / (max - min));
        CGFloat x = i * barWidth;
        CGRect frame = CGRectMake(x, fullHeight - barHeight, barWidth, barHeight);
        UIView* barView = [[UIView alloc] initWithFrame:frame];
        UIView* lineBarView = [[UIView alloc] initWithFrame:CGRectInset(frame, -1, -1)];
        CAGradientLayer* layer = [CAGradientLayer layer];
        layer.locations = @[ @0, @1 ];
        layer.startPoint = CGPointZero;
        layer.endPoint = CGPointMake(0, 1);
        layer.frame = CGRectMake(0, barHeight - fullHeight, barWidth, fullHeight);
        layer.colors = @[ (id)[UIColor trendGraphTopColor].CGColor,
            (id)[UIColor trendGraphBottomColor].CGColor ];
        [barView.layer insertSublayer:layer atIndex:0];
        barView.layer.masksToBounds = YES;
        lineBarView.backgroundColor = [[UIColor tintColor] colorWithAlphaComponent:0.4f];
        [self addSubview:barView];
        [self insertSubview:lineBarView atIndex:0];
    }
}

@end
