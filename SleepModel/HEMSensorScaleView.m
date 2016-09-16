//
//  HEMSensorScaleView.m
//  Sense
//
//  Created by Jimmy Lu on 9/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "NSBundle+HEMUtils.h"

#import "HEMStyle.h"
#import "HEMSensorScaleView.h"

CGFloat const kHEMSensorScaleHeight = 56.0f;

@implementation HEMSensorScaleView

+ (instancetype)scaleView {
    return [NSBundle loadNibWithOwner:self];
}

- (void)awakeFromNib {
    [[self nameLabel] setFont:[UIFont body]];
    [[self nameLabel] setTextColor:[UIColor grey6]];
    [[self rangeLabel] setFont:[UIFont body]];
    [[self rangeLabel] setTextColor:[UIColor grey5]];
    
    CGFloat conditionSize = CGRectGetWidth([[self conditionView] bounds]);
    [[[self conditionView] layer] setCornerRadius:conditionSize / 2.0f];
    
    [[self separatorView] setBackgroundColor:[UIColor separatorColor]];
}

@end
