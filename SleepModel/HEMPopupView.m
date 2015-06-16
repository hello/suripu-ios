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
    [[UIColor whiteColor] setFill];
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat boxHeight = CGRectGetHeight(rect) - HEMPopupPointerHeight;
    CGRect containerRect = CGRectMake(minX, minY, CGRectGetWidth(rect), boxHeight);
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRoundedRect:containerRect cornerRadius:4];
    [rectanglePath fill];
}

@end
