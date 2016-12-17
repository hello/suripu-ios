//
//  HEMSensorAboutCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "NSString+HEMUtils.h"

#import "HEMSensorAboutCollectionViewCell.h"
#import "HEMStyle.h"

static CGFloat const kHEMSensorAboutTextSpacing = 10.0f;
static CGFloat const kHEMSensorAboutCellHorzPadding = 24.0f;

@implementation HEMSensorAboutCollectionViewCell

+ (CGFloat)heightWithTitle:(NSString*)title about:(NSString*)about maxWidth:(CGFloat)width {
    CGFloat widthConstraint = width - (kHEMSensorAboutCellHorzPadding * 2);
    UIFont* font = [UIFont h6];
    NSDictionary* attrs = @{NSFontAttributeName : font};
    CGFloat titleHeight = [title sizeBoundedByWidth:widthConstraint attriburtes:attrs].height;
    
    font = [UIFont body];
    attrs = @{NSFontAttributeName : font};
    CGFloat aboutHeight = [about sizeBoundedByWidth:widthConstraint attriburtes:attrs].height;
    return titleHeight + kHEMSensorAboutTextSpacing + aboutHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self titleLabel] setFont:[UIFont h6Bold]];
    [[self titleLabel] setTextColor:[UIColor grey6]];
    [[self aboutLabel] setFont:[UIFont body]];
    [[self aboutLabel] setTextColor:[UIColor grey5]];
}

@end
