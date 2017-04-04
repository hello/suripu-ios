//
//  HEMDescriptionHeaderView.m
//  Sense
//
//  Created by Jimmy Lu on 8/31/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "NSAttributedString+HEMUtils.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "Sense-Swift.h"

#import "HEMDescriptionHeaderView.h"
#import "HEMStyle.h"

static CGFloat const HEMDescriptionHeaderBaseImageHeight = 182.0f;
static CGFloat const HEMDescriptionHeaderTitleTopMargin = 13.0f;
static CGFloat const HEMDescriptionHeaderTextSpacing = 8.0f;
static CGFloat const HEMDescriptionHeaderDescBotMargin = 32.0f;

@implementation HEMDescriptionHeaderView

+ (CGFloat)heightWithTitle:(NSAttributedString*)title
               description:(NSAttributedString*)description
           widthConstraint:(CGFloat)width {
    CGFloat titleHeight = [title sizeWithWidth:width].height;
    CGFloat descHeight = [description sizeWithWidth:width].height;
    return HEMDescriptionHeaderBaseImageHeight
            + HEMDescriptionHeaderTitleTopMargin
            + titleHeight
            + HEMDescriptionHeaderTextSpacing
            + descHeight
            + HEMDescriptionHeaderDescBotMargin;
}

+ (NSAttributedString*)attributedText:(NSString*)text
                     forColorProperty:(enum ThemeProperty)colorProp
                         fontProperty:(enum ThemeProperty)fontProp {
    UIColor* color = [SenseStyle colorWithAClass:self property:colorProp];
    UIFont* font = [SenseStyle fontWithAClass:self property:fontProp];
    
    NSMutableParagraphStyle* style = DefaultBodyParagraphStyle();
    [style setAlignment:NSTextAlignmentCenter];
    
    NSMutableDictionary* attrs = [NSMutableDictionary dictionaryWithCapacity:3];
    attrs[NSParagraphStyleAttributeName] = style;
    
    if (font) {
        attrs[NSFontAttributeName] = font;
    }
    
    if (color) {
        attrs[NSForegroundColorAttributeName] = color;
    }
    
    return [[NSAttributedString alloc] initWithString:text attributes:attrs];
}

+ (NSAttributedString*)attributedTitle:(NSString*)title {
    return [self attributedText:title
               forColorProperty:ThemePropertyTextColor
                   fontProperty:ThemePropertyTextFont];
}

+ (NSAttributedString*)attributedDescription:(NSString*)description {
    return [self attributedText:description
               forColorProperty:ThemePropertyDetailColor
                   fontProperty:ThemePropertyDetailFont];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self descriptionLabel] setNumberOfLines:0];
}

@end
