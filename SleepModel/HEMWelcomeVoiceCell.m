//
//  HEMWelcomeVoiceCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMWelcomeVoiceCell.h"
#import "NSString+HEMUtils.h"

static CGFloat kHEMWelcomeVoiceBaseCellHeight = 228.0f;
static CGFloat kHEMWelcomeVoiceTextMargin = 20.0f;

@implementation HEMWelcomeVoiceCell

+ (CGFloat)heightWithMessage:(NSString*)message
                    withFont:(UIFont*)font
                   cellWidth:(CGFloat)cellWidth {
    CGFloat labelWidth = cellWidth - (kHEMWelcomeVoiceTextMargin * 2.0f);
    CGFloat height = [message heightBoundedByWidth:labelWidth usingFont:font];
    return kHEMWelcomeVoiceBaseCellHeight + height;
}

- (void)applyStyle {
    [super applyStyle];
    
    UIColor* color = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIColor* messageColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIFont* messageFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    UIColor* separatorColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertySeparatorColor];
    [[self titleLabel] setFont:font];
    [[self titleLabel] setTextColor:color];
    [[self messageLabel] setFont:messageFont];
    [[self messageLabel] setTextColor:messageColor];
    [[self separator] setBackgroundColor:separatorColor];
    [[self closeButton] applySecondaryStyle];
}

@end
