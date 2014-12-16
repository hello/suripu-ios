//
//  HEMAnswerCell.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSingleResponseCell.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

@implementation HEMSingleResponseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView* selectedView = [[UIView alloc] initWithFrame:[[self contentView] bounds]];
    [selectedView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [selectedView setBackgroundColor:[HelloStyleKit questionAnswerSelectedBgColor]];
    [self setSelectedBackgroundView:selectedView];
}

@end