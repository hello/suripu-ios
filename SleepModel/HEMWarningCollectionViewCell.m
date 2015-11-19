//
//  HEMWarningCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/8/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMWarningCollectionViewCell.h"
#import "HEMActionButton.h"

CGFloat const HEMWarningCellBaseHeight = 170.0f;
CGFloat const HEMWarningCellMessageHorzPadding = 24.0f;

@implementation HEMWarningCollectionViewCell

- (void)awakeFromNib {
    [[self warningSummaryLabel] setFont:[UIFont deviceCellWarningSummaryFont]];
    [[self warningMessageLabel] setFont:[UIFont deviceCellWarningMessageFont]];
}

@end
