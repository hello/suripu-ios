//
//  HEMPopupLabel.m
//  Sense
//
//  Created by Delisa Mason on 2/13/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMPopupView.h"
#import "HelloStyleKit.h"

@interface HEMPopupView ()

@property (nonatomic, strong) IBOutlet UILabel* label;
@end

@implementation HEMPopupView

static CGFloat const HEMPopupPointerHeight = 6.f;
static CGFloat const HEMPopupPointerRadius = 8.f;
static CGFloat const HEMPopupMargin = 20.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [self.label intrinsicContentSize];
    size.height += HEMPopupPointerHeight + HEMPopupMargin;
    size.width += HEMPopupMargin;
    return size;
}


- (void)setText:(NSString *)text
{
    self.label.text = text;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [[HelloStyleKit tintColor] setFill];
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat midX = CGRectGetMidX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat boxHeight = CGRectGetHeight(rect) - HEMPopupPointerHeight;
    [bezierPath moveToPoint: CGPointMake(midX - HEMPopupPointerRadius, boxHeight)];
    [bezierPath addLineToPoint: CGPointMake(midX, boxHeight + HEMPopupPointerHeight)];
    [bezierPath addLineToPoint: CGPointMake(midX + HEMPopupPointerRadius, boxHeight)];
    [bezierPath closePath];
    [bezierPath fill];

    CGRect containerRect = CGRectMake(minX, minY, CGRectGetWidth(rect), boxHeight);
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:containerRect cornerRadius: 4];
    [rectanglePath fill];
}

@end
