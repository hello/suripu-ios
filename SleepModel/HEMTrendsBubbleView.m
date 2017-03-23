//
//  HEMTrendsBubbleView.m
//  Sense
//
//  Created by Jimmy Lu on 2/16/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <UICountingLabel/UICountingLabel.h>
#import "Sense-Swift.h"
#import "HEMTrendsBubbleView.h"

@implementation HEMTrendsBubbleView

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self valueLabel] setFormat:@"%.0f"];
    [self applyStyle];
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

- (void)applyStyle {
    UIColor* valueColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIColor* unitColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    UIColor* titleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor];
    UIFont* valueFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIFont* unitFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    [[self valueLabel] setTextColor:valueColor];
    [[self unitLabel] setTextColor:unitColor];
    [[self nameLabel] setTextColor:titleColor];
    [[self valueLabel] setFont:valueFont];
    [[self unitLabel] setFont:unitFont];
    [[self nameLabel] setFont:titleFont];
    [[self nameLabel] setBackgroundColor:[UIColor clearColor]];
    [[self unitLabel] setBackgroundColor:[UIColor clearColor]];
    [[self valueLabel] setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor clearColor]];
}

@end
