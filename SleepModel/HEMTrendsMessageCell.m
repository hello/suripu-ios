//
//  HEMTrendsMessageCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "NSAttributedString+HEMUtils.h"
#import "HEMTrendsMessageCell.h"

static CGFloat const HEMTrendsMessageCellVertPadding = 28.0f;
static CGFloat const HEMTrendsMessageCellImageHeight = 112.0f;
static CGFloat const HEMTrendsMessageCellTextHorzPadding = 20.0f;
static CGFloat const HEMTrendsMessageCellTitleTopPadding = 24.0f;
static CGFloat const HEMTrendsMessageCellTitleBotPadding = 4.0f;

@implementation HEMTrendsMessageCell

+ (CGFloat)heightWithTitle:(NSAttributedString*)title
                   message:(NSAttributedString*)message
                 withWidth:(CGFloat)width {
    
    CGFloat height = HEMTrendsMessageCellVertPadding;
    height += HEMTrendsMessageCellImageHeight;
    height += HEMTrendsMessageCellTitleTopPadding;
    
    CGFloat maxTextWidth = width - (HEMTrendsMessageCellTextHorzPadding * 2);
    CGFloat titleHeight = [title sizeWithWidth:maxTextWidth].height;
    CGFloat messageHeight = [message sizeWithWidth:maxTextWidth].height;
    
    height += titleHeight;
    height += HEMTrendsMessageCellTitleBotPadding;
    height += messageHeight;
    height += HEMTrendsMessageCellVertPadding;
    
    return ceilCGFloat(height);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self imageView] setContentMode:UIViewContentModeCenter];
    [[self messageLabel] setNumberOfLines:0];
}

@end
