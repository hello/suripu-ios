//
//  HEMSensorCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "NSString+HEMUtils.h"

#import "HEMSensorCollectionViewCell.h"
#import "HEMStyle.h"

static CGFloat const HEMSensorCellPadding = 16.0f;
static CGFloat const HEMSensorCellNameHeight = 24.0f;
static CGFloat const HEMSensorCellGraphHeight = 112.0f;
static CGFloat const HEMSensorCellTextWidthRatio = 0.75f;

@implementation HEMSensorCollectionViewCell

+ (CGFloat)heightWithDescription:(NSString*)description cellWidth:(CGFloat)cellWidth {
    CGFloat widthMinusPadding = cellWidth - (HEMSensorCellPadding * 2);
    CGFloat maxTextWidth = widthMinusPadding * HEMSensorCellTextWidthRatio;
    CGFloat totalHeight = HEMSensorCellPadding;
    totalHeight += HEMSensorCellNameHeight;
    totalHeight += [description heightBoundedByWidth:maxTextWidth usingFont:[UIFont body]];
    totalHeight += HEMSensorCellPadding;
    totalHeight += HEMSensorCellGraphHeight;
    return totalHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self descriptionLabel] setFont:[UIFont body]];
    [[self descriptionLabel] setTextColor:[UIColor grey5]];
    [[self nameLabel] setFont:[UIFont h7Bold]];
    [[self nameLabel] setTextColor:[UIColor grey6]];
    [[self valueLabel] setFont:[UIFont h4]];
}

@end
