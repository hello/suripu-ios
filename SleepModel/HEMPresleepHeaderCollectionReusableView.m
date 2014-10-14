//
//  HEMPreSleepCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 10/10/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMPresleepHeaderCollectionReusableView.h"
#import "HEMTimelineDrawingUtils.h"
#import "HelloStyleKit.h"

@interface HEMPresleepHeaderCollectionReusableView ()

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@end

@implementation HEMPresleepHeaderCollectionReusableView

static CGFloat const HEMPresleepSummaryShadowHeight = 5.f;
static CGFloat const HEMPresleepSummaryInsetHeight = 15.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"sleep-history.presleep-state.title", nil) uppercaseString]
                                                                     attributes:@{
                                                                         NSKernAttributeName : @(2.5)
                                                                     }];
}

- (void)drawRect:(CGRect)rect
{
    [self drawShadowGradientInRect:rect];
}

- (void)drawShadowGradientInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.97f alpha:1.f].CGColor);
    CGRect contentRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + HEMPresleepSummaryShadowHeight + HEMPresleepSummaryInsetHeight, CGRectGetWidth(rect), CGRectGetHeight(rect) - HEMPresleepSummaryShadowHeight - HEMPresleepSummaryInsetHeight);
    CGContextFillRect(ctx, contentRect);

    CGRect shadowRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + HEMPresleepSummaryInsetHeight, CGRectGetWidth(rect), HEMPresleepSummaryShadowHeight);

    CGFloat colors[] = {
        0.302, 0.31, 0.306, 0.0,
        0.41, 0.42, 0.42, 0.1,
    };
    [HEMTimelineDrawingUtils drawVerticalGradientInRect:shadowRect withColors:colors];
}

@end
