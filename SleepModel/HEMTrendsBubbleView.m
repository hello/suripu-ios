//
//  HEMTrendsBubbleView.m
//  Sense
//
//  Created by Jimmy Lu on 2/16/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <UICountingLabel/UICountingLabel.h>
#import "HEMTrendsBubbleView.h"
#import "HEMStyle.h"

@implementation HEMTrendsBubbleView

- (void)awakeFromNib {
    [self setBackgroundColor:[UIColor clearColor]];
    [[self valueLabel] setBackgroundColor:[UIColor clearColor]];
    [[self valueLabel] setTextColor:[UIColor whiteColor]];
    [[self valueLabel] setFont:[UIFont trendSleepDepthValueFontWithSize:35.0f]];
    [[self valueLabel] setFormat:@"%.0f"];
    
    [[self unitLabel] setFont:[UIFont trendSleepDepthValueFontWithSize:23.0f]];
    [[self unitLabel] setBackgroundColor:[UIColor clearColor]];
    [[self unitLabel] setTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]];
    
    [[self nameLabel] setBackgroundColor:[UIColor clearColor]];
    [[self nameLabel] setFont:[UIFont trendSleepDepthTitleFont]];
    [[self nameLabel] setTextColor:[UIColor whiteColor]];
}

- (void)drawRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGRect bubbleFrame = CGRectZero;
    bubbleFrame.size = CGSizeMake(width, width);
    bubbleFrame.origin.y = (height - width) / 2.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [[self bubbleColor] CGColor]);
    
    NSShadow* circleShadow = [NSShadow shadowForTrendsSleepDepthCircles];
    CGSize shadowOffset = [circleShadow shadowOffset];
    CGContextSetShadowWithColor(context,
                                shadowOffset,
                                [circleShadow shadowBlurRadius],
                                [[circleShadow shadowColor] CGColor]);
    
    CGContextFillEllipseInRect (context, CGRectInset(bubbleFrame,
                                                     shadowOffset.height,
                                                     shadowOffset.height));
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    [super drawRect:rect];
}


@end
