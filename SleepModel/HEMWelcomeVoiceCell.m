//
//  HEMWelcomeVoiceCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

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

@end
