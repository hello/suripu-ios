//
//  HEMEventBubbleView.m
//  Sense
//
//  Created by Delisa Mason on 5/21/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMEventBubbleView.h"
#import "HelloStyleKit.h"
#import "NSAttributedString+HEMUtils.h"

@interface HEMEventBubbleView ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@end

@implementation HEMEventBubbleView

CGFloat const HEMEventBubbleTextWidthOffset = 149.f;
CGFloat const HEMEventBubbleWidthOffset = 36.f;
CGFloat const HEMEventBubbleTextHeightOffset = 26.f;

- (void)awakeFromNib {
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 1.5f;
    self.layer.shadowColor = [HelloStyleKit tintColor].CGColor;
    self.layer.shadowOpacity = 0.2f;
    self.layer.cornerRadius = 3.f;
    self.backgroundColor = [UIColor whiteColor];
}

- (CGSize)intrinsicContentSize {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(screenSize) - HEMEventBubbleTextWidthOffset;
    CGSize textSize = [self.textLabel.attributedText sizeWithWidth:width];
    return CGSizeMake(CGRectGetWidth(screenSize) - HEMEventBubbleWidthOffset,
                      textSize.height + HEMEventBubbleTextHeightOffset);
}

@end
