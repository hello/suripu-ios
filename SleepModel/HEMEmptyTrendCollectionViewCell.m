//
//  HEMEmptyTrendCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 1/15/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "NSString+HEMUtils.h"

#import "HEMEmptyTrendCollectionViewCell.h"

static CGFloat const HEMEmptyTrendImageHeight = 180.0f;
static CGFloat const HEMEmptyTrendHorzMargin = 40.0f;
static CGFloat const HEMEmptyTrendVertMargin = 24.0f;

@implementation HEMEmptyTrendCollectionViewCell

+ (CGFloat)heightWithDescription:(NSString*)description cellWidth:(CGFloat)width {
    NSDictionary* attrs = @{NSFontAttributeName : [UIFont emptyStateDescriptionFont],
                           NSForegroundColorAttributeName : [UIColor emptyStateDescriptionColor]};
    
    CGFloat actualWidth = width - (HEMEmptyTrendHorzMargin * 2);
    CGFloat textHeight = [description heightBoundedByWidth:actualWidth attributes:attrs];
    return HEMEmptyTrendImageHeight + textHeight + (HEMEmptyTrendVertMargin * 2);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self detailLabel] setFont:[UIFont emptyStateDescriptionFont]];
    [[self detailLabel] setTextColor:[UIColor emptyStateDescriptionColor]];
}

@end
