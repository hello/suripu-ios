//
//  HEMIntroMessageCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "NSAttributedString+HEMUtils.h"
#import "HEMIntroMessageCell.h"

static CGFloat const HEMIntroMessageCellVertPadding = 28.0f;
static CGFloat const HEMIntroMessageCellImageHeight = 112.0f;
static CGFloat const HEMIntroMessageCellTextHorzPadding = 20.0f;
static CGFloat const HEMIntroMessageCellTitleTopPadding = 24.0f;
static CGFloat const HEMIntroMessageCellTitleBotPadding = 4.0f;

@implementation HEMIntroMessageCell

+ (CGFloat)heightWithTitle:(NSAttributedString*)title
                   message:(NSAttributedString*)message
                 withWidth:(CGFloat)width {
    
    CGFloat height = HEMIntroMessageCellVertPadding;
    height += HEMIntroMessageCellImageHeight;
    height += HEMIntroMessageCellTitleTopPadding;
    
    CGFloat maxTextWidth = width - (HEMIntroMessageCellTextHorzPadding * 2);
    CGFloat titleHeight = [title sizeWithWidth:maxTextWidth].height;
    CGFloat messageHeight = [message sizeWithWidth:maxTextWidth].height;
    
    height += titleHeight;
    height += HEMIntroMessageCellTitleBotPadding;
    height += messageHeight;
    height += HEMIntroMessageCellVertPadding;
    
    return ceilCGFloat(height);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self imageView] setContentMode:UIViewContentModeCenter];
    [[self messageLabel] setNumberOfLines:0];
}

@end
