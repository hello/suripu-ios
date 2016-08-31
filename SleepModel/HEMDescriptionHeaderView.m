//
//  HEMDescriptionHeaderView.m
//  Sense
//
//  Created by Jimmy Lu on 8/31/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "NSAttributedString+HEMUtils.h"

#import "HEMDescriptionHeaderView.h"
#import "HEMStyle.h"

static CGFloat const HEMDescriptionHeaderBaseImageHeight = 182.0f;
static CGFloat const HEMDescriptionHeaderTitleTopMargin = 13.0f;
static CGFloat const HEMDescriptionHeaderTextSpacing = 8.0f;
static CGFloat const HEMDescriptionHeaderDescBotMargin = 40.0f;

@implementation HEMDescriptionHeaderView

+ (CGFloat)heightWithTitle:(NSAttributedString*)title
               description:(NSAttributedString*)description
           widthConstraint:(CGFloat)width {
    CGFloat titleHeight = [title sizeWithWidth:width].height;
    return 0.0f;
}

@end
