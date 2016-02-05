//
//  HEMTrendsBaseCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBaseCell.h"
#import "HEMStyle.h"

@implementation HEMTrendsBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self titleLabel] setFont:[UIFont trendsTitleFont]];
    [[self titleLabel] setTextColor:[UIColor trendsTitleColor]];
    [[self titleSeparator] setBackgroundColor:[UIColor trendsTitleDividerColor]];
}


@end
