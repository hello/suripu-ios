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
static CGFloat const HEMPopupMargin = 20.f;

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
}

- (CGSize)intrinsicContentSize {
    CGRect bounds = [self.label.attributedText
        boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.bounds) - HEMPopupMargin, CGFLOAT_MAX)
                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                     context:nil];
    CGSize size = bounds.size;
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
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Shadow Declarations
    CGFloat blurRadius = 6;
    NSShadow *sleepDepthPointerShadow = [NSShadow shadowWithColor:[HelloStyleKit.tintColor colorWithAlphaComponent:0.19]
                                                           offset:CGSizeMake(4.1, 4.1)
                                                       blurRadius:blurRadius];

    //// Group
    {
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, sleepDepthPointerShadow.shadowOffset,
                                    sleepDepthPointerShadow.shadowBlurRadius,
                                    [sleepDepthPointerShadow.shadowColor CGColor]);
        CGContextBeginTransparencyLayer(context, NULL);

        //// Rectangle Drawing
        CGFloat inset = 20.63;
        CGRect fill
            = CGRectMake(inset, 0.73, CGRectGetWidth(rect) - inset - blurRadius, CGRectGetHeight(rect) - blurRadius);
        UIBezierPath *rectanglePath =
            [UIBezierPath bezierPathWithRoundedRect:fill
                                  byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                        cornerRadii:CGSizeMake(7, 7)];
        [rectanglePath closePath];
        [UIColor.whiteColor setFill];
        [rectanglePath fill];

        //// Rectangle 2 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0, 20.23);
        CGContextRotateCTM(context, -45 * M_PI / 180);

        UIBezierPath *rectangle2Path = [UIBezierPath
            bezierPathWithRoundedRect:CGRectMake(0, 0, 29.61, 30)
                    byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight
                          cornerRadii:CGSizeMake(4, 4)];
        [rectangle2Path closePath];
        [UIColor.whiteColor setFill];
        [rectangle2Path fill];

        CGContextRestoreGState(context);

        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
}

@end
