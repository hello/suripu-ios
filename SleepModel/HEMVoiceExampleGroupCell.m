//
//  HEMVoiceExampleGroupCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceExampleGroupCell.h"
#import "NSString+HEMUtils.h"
#import "NSAttributedString+HEMUtils.h"

static CGFloat const kHEMVoiceExampleCellTextSpacing = 8.0f;
static CGFloat const kHEMVoiceExampleCellTextMargin = 32.0f;

@implementation HEMVoiceExampleGroupCell

+ (CGFloat)heightWithCategoryName:(NSString*)categoryName
                     categoryFont:(UIFont*)categoryFont
                         examples:(NSAttributedString*)examples
                        cellWidth:(CGFloat)cellWidth {
    CGFloat labelWidth = cellWidth - (kHEMVoiceExampleCellTextMargin * 2);
    CGFloat categoryHeight = [categoryName heightBoundedByWidth:labelWidth
                                                      usingFont:categoryFont];
    CGFloat examplesHeight = [examples sizeWithWidth:labelWidth].height;
    return categoryHeight + kHEMVoiceExampleCellTextSpacing + examplesHeight;
}

@end
