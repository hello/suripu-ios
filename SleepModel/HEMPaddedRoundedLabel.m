//
//  HEMPaddedRoundedLabel.m
//  Sense
//
//  Created by Delisa Mason on 10/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMPaddedRoundedLabel.h"

@implementation HEMPaddedRoundedLabel

static CGFloat const HEMPaddedRoundedLabelHeight = 24.f;
static CGFloat const HEMPaddedRoundedLabelVerticalPadding = 2.f;

- (void)awakeFromNib
{
    self.layer.cornerRadius = floorf(HEMPaddedRoundedLabelHeight / 2);
}

- (void)drawRect:(CGRect)rect
{
    NSDictionary* attributes = @{ NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.textColor };
    CGSize textSize = [self.text sizeWithAttributes:attributes];
    CGFloat verticalInset = floorf((CGRectGetHeight(rect) - textSize.height) / 2) + HEMPaddedRoundedLabelVerticalPadding;
    CGFloat horizontalInset = floorf((CGRectGetWidth(rect) - textSize.width) / 2);
    [self.text drawAtPoint:CGPointMake(horizontalInset, verticalInset)
            withAttributes:attributes];
}

@end
