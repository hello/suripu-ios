//
//  HEMVoiceGroupHeaderCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceGroupHeaderCell.h"
#import "NSString+HEMUtils.h"

static CGFloat const kHEMVoiceGroupImageSize = 64.0f;
static CGFloat const kHEMVoiceGroupImageToCategorySpacing = 18.0f;
static CGFloat const kHEMVoiceGroupTextSpacing = 8.0f;
static CGFloat const kHEMVoiceGroupTextMargin = 32.0f;

@implementation HEMVoiceGroupHeaderCell

+ (CGFloat)heightWithCategory:(NSString*)category
                 categoryFont:(UIFont*)categoryFont
                      message:(NSString*)message
                  messageFont:(UIFont*)messageFont
                    fullWidth:(CGFloat)width {
    CGFloat labelWidth = width - (kHEMVoiceGroupTextMargin * 2);
    CGFloat categoryHeight = [category heightBoundedByWidth:labelWidth usingFont:categoryFont];
    CGFloat messageHeight = [message heightBoundedByWidth:labelWidth usingFont:messageFont];
    return kHEMVoiceGroupImageSize
        + kHEMVoiceGroupImageToCategorySpacing
        + categoryHeight
        + kHEMVoiceGroupTextSpacing
        + messageHeight;
}

@end
