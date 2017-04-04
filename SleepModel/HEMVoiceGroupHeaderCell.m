//
//  HEMVoiceGroupHeaderCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMVoiceGroupHeaderCell.h"
#import "NSString+HEMUtils.h"

static CGFloat const kHEMVoiceGroupImageSize = 64.0f;
static CGFloat const kHEMVoiceGroupImageToCategorySpacing = 18.0f;
static CGFloat const kHEMVoiceGroupTextSpacing = 8.0f;
static CGFloat const kHEMVoiceGroupTextMargin = 32.0f;

@implementation HEMVoiceGroupHeaderCell

+ (CGFloat)heightWithCategory:(NSString*)category message:(NSString*)message fullWidth:(CGFloat)width {
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    UIFont* messageFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    CGFloat labelWidth = width - (kHEMVoiceGroupTextMargin * 2);
    CGFloat categoryHeight = [category heightBoundedByWidth:labelWidth usingFont:font];
    CGFloat messageHeight = [message heightBoundedByWidth:labelWidth usingFont:messageFont];
    return kHEMVoiceGroupImageSize
        + kHEMVoiceGroupImageToCategorySpacing
        + categoryHeight
        + kHEMVoiceGroupTextSpacing
        + messageHeight;
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
    [[self messageLabel] setFont:messageFont];
    [[self messageLabel] setTextColor:messageColor];
}

@end
