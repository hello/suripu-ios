//
//  HEMPopupLabel.m
//  Sense
//
//  Created by Delisa Mason on 2/13/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <AttributedMarkdown/markdown_peg.h>
#import "HEMPopupView.h"
#import "HelloStyleKit.h"
#import "HEMMarkdown.h"
#import "NSAttributedString+HEMUtils.h"

@interface HEMPopupView ()

@property (nonatomic, strong) IBOutlet UILabel *label;
@end

@implementation HEMPopupView

static CGFloat const HEMPopupPointerHeight = 6.f;
static CGFloat const HEMPopupMargin = 30.f;
static CGFloat const HEMPopupShadowBlur = 2.f;

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
}

- (CGSize)intrinsicContentSize {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGSize size = [self.label.attributedText sizeWithWidth:CGRectGetWidth(screenBounds) - HEMPopupMargin];
    size.height += HEMPopupPointerHeight + HEMPopupMargin;
    size.width += HEMPopupMargin;
    return size;
}

- (void)setText:(NSString *)text {
    NSAttributedString *labelText =
        [markdown_to_attr_string(text, 0, [HEMMarkdown attributesForTimelineSegmentPopup]) trim];
    self.label.attributedText = labelText;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetShadowWithColor(ctx, CGSizeZero, HEMPopupShadowBlur,
                                [[[HelloStyleKit tintColor] colorWithAlphaComponent:0.25f] CGColor]);
    CGContextBeginTransparencyLayer(ctx, NULL);
    CGFloat inset = floorf(HEMPopupMargin / 4);
    CGRect fill = CGRectInset(rect, HEMPopupShadowBlur, inset);
    fill.size.height -= HEMPopupPointerHeight;
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRoundedRect:fill cornerRadius:3.f];
    [rectanglePath closePath];
    [UIColor.whiteColor setFill];
    [rectanglePath fill];

    UIBezierPath *pointerPath = [UIBezierPath bezierPath];
    CGFloat pointerLeftEdge = HEMPopupPointerHeight * 2;
    CGFloat pointerTopEdge = CGRectGetMaxY(fill);
    [pointerPath moveToPoint:CGPointMake(pointerLeftEdge, pointerTopEdge)];
    [pointerPath
        addLineToPoint:CGPointMake(pointerLeftEdge + HEMPopupPointerHeight, pointerTopEdge + HEMPopupPointerHeight)];
    [pointerPath addLineToPoint:CGPointMake(pointerLeftEdge + HEMPopupPointerHeight * 2, pointerTopEdge)];
    [pointerPath closePath];
    [[UIColor whiteColor] setFill];
    [pointerPath fill];

    CGContextEndTransparencyLayer(ctx);
    CGContextRestoreGState(ctx);
}

@end
