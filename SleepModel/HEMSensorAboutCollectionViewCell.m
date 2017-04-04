//
//  HEMSensorAboutCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "NSString+HEMUtils.h"
#import "NSAttributedString+HEMUtils.h"

#import "HEMSensorAboutCollectionViewCell.h"

static CGFloat const kHEMSensorAboutTextSpacing = 10.0f;
static CGFloat const kHEMSensorAboutCellHorzPadding = 24.0f;

@implementation HEMSensorAboutCollectionViewCell

+ (NSDictionary*)aboutAttributes {
    UIColor* aboutColor = [SenseStyle colorWithAClass:self
                                             property:ThemePropertyDetailColor];
    UIFont* aboutFont = [SenseStyle fontWithAClass:self
                                          property:ThemePropertyDetailFont];
    
    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithCapacity:3];
    attributes[NSParagraphStyleAttributeName] = [NSMutableParagraphStyle senseStyle];
    if (aboutFont) {
        attributes[NSFontAttributeName] = aboutFont;
    }
    if (aboutColor) {
        attributes[NSForegroundColorAttributeName] = aboutColor;
    }
    return attributes;
}

+ (NSDictionary*)boldAboutAttributes {
    NSMutableDictionary* attributes = [[self aboutAttributes] mutableCopy];
    UIColor* color = [SenseStyle colorWithAClass:self property:ThemePropertyTextColor];
    if (color) {
        attributes[NSForegroundColorAttributeName] = color;
    }
    return attributes;
}

+ (CGFloat)heightWithTitle:(NSString*)title about:(NSAttributedString*)about maxWidth:(CGFloat)width {
    CGFloat widthConstraint = width - (kHEMSensorAboutCellHorzPadding * 2);
    UIFont* font = [SenseStyle fontWithAClass:self property:ThemePropertyTextFont];
    NSDictionary* attrs = font ? @{NSFontAttributeName : font} : nil;
    CGFloat titleHeight = [title sizeBoundedByWidth:widthConstraint attriburtes:attrs].height;
    CGFloat aboutHeight = [about sizeWithWidth:widthConstraint].height;
    return titleHeight + kHEMSensorAboutTextSpacing + aboutHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyStyle];
}

- (void)applyStyle {
    UIColor* titleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIColor* aboutColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    UIFont* aboutFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    
    [[self titleLabel] setFont:titleFont];
    [[self titleLabel] setTextColor:titleColor];
    [[self aboutLabel] setFont:aboutFont];
    [[self aboutLabel] setTextColor:aboutColor];
}

@end
