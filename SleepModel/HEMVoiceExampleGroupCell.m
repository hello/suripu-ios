//
//  HEMVoiceExampleGroupCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMVoiceExampleGroupCell.h"
#import "NSString+HEMUtils.h"
#import "NSAttributedString+HEMUtils.h"

static CGFloat const kHEMVoiceExampleCellTextSpacing = 8.0f;
static CGFloat const kHEMVoiceExampleCellTextMargin = 32.0f;

@implementation HEMVoiceExampleGroupCell

+ (NSDictionary*)examplesAttributes {
    UIFont* messageFont = [SenseStyle fontWithAClass:self property:ThemePropertyTextFont];
    UIColor* messageColor = [SenseStyle colorWithAClass:self property:ThemePropertyTextColor];
    NSMutableParagraphStyle* pStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [pStyle setParagraphSpacing:kHEMVoiceExampleCellTextSpacing];
    [pStyle setAlignment:NSTextAlignmentCenter];
    return @{NSFontAttributeName : messageFont,
             NSForegroundColorAttributeName : messageColor,
             NSParagraphStyleAttributeName : pStyle};
}

+ (CGFloat)heightWithCategoryName:(NSString*)categoryName
                         examples:(NSAttributedString*)examples
                        cellWidth:(CGFloat)cellWidth {
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    CGFloat labelWidth = cellWidth - (kHEMVoiceExampleCellTextMargin * 2);
    CGFloat categoryHeight = [categoryName heightBoundedByWidth:labelWidth usingFont:font];
    CGFloat examplesHeight = [examples sizeWithWidth:cellWidth].height;
    return categoryHeight + kHEMVoiceExampleCellTextSpacing + examplesHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyStyle];
}

- (void)applyStyle {
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    UIColor* color = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor];
    UIFont* messageFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIColor* messageColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    [[self categoryLabel] setFont:font];
    [[self categoryLabel] setTextColor:color];
    [[self examplesLabel] setFont:messageFont];
    [[self examplesLabel] setTextColor:messageColor];
}

@end
