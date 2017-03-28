//
//  HEMIntroMessageCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMIntroMessageCell.h"

static CGFloat const HEMIntroMessageCellVertPadding = 28.0f;
static CGFloat const HEMIntroMessageCellImageHeight = 112.0f;
static CGFloat const HEMIntroMessageCellTextHorzPadding = 20.0f;
static CGFloat const HEMIntroMessageCellTitleTopPadding = 24.0f;
static CGFloat const HEMIntroMessageCellTitleBotPadding = 4.0f;

@implementation HEMIntroMessageCell

+ (NSDictionary*)titleAttributes {
    NSMutableParagraphStyle* para = DefaultBodyParagraphStyle();
    [para setAlignment:NSTextAlignmentCenter];
    return @{NSForegroundColorAttributeName : [SenseStyle colorWithAClass:[self class]
                                                                 property:ThemePropertyTitleColor],
             NSFontAttributeName : [SenseStyle fontWithAClass:[self class]
                                                     property:ThemePropertyTitleFont],
             NSParagraphStyleAttributeName : para};
}
    
+ (NSDictionary*)messageAttributes {
    NSMutableParagraphStyle* para = DefaultBodyParagraphStyle();
    [para setAlignment:NSTextAlignmentCenter];
    return @{NSForegroundColorAttributeName : [SenseStyle colorWithAClass:[self class]
                                                                 property:ThemePropertyTextColor],
             NSFontAttributeName : [SenseStyle fontWithAClass:[self class]
                                                     property:ThemePropertyTextFont],
             NSParagraphStyleAttributeName : para};
}

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
    [self applyStyle];
    [[self imageView] setContentMode:UIViewContentModeCenter];
    [[self imageView] setBackgroundColor:[self backgroundColor]];
    [[self messageLabel] setNumberOfLines:0];
}

@end
