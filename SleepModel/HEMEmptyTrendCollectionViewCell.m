//
//  HEMEmptyTrendCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 1/15/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMEmptyTrendCollectionViewCell.h"


@implementation HEMEmptyTrendCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self detailLabel] setFont:[UIFont emptyStateDescriptionFont]];
}

@end
