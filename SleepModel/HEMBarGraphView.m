//
//  HEMBarGraphView.m
//  Sense
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENTrend.h>
#import "HEMBarGraphView.h"
#import "HelloStyleKit.h"

@implementation HEMBarGraphView

- (void)setValues:(NSArray *)values
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
    CGFloat barWidth = CGRectGetWidth(self.bounds)/self.values.count;
    CGFloat fullHeight = CGRectGetHeight(self.bounds);
    for (int i = 0; i < self.values.count; i++) {
        SENTrendDataPoint* point = self.values[i];
        CGFloat barHeight;
        if (max == min)
            barHeight = 0;
        else
            barHeight = fullHeight * ((point.yValue - min)/(max - min));
        CGRect frame = CGRectMake(i * barWidth, fullHeight - barHeight, barWidth, barHeight);
        UIView* barView = [[UIView alloc] initWithFrame:frame];
        UIView* lineBarView = [[UIView alloc] initWithFrame:CGRectInset(frame, -1, -1)];
        barView.backgroundColor = [UIColor colorWithHue:0.56 saturation:0.07 brightness:1 alpha:1];
        lineBarView.backgroundColor = [UIColor colorWithHue:0.56 saturation:0.4 brightness:1 alpha:1];
        [self addSubview:barView];
        [self insertSubview:lineBarView atIndex:0];
    }
}

@end
