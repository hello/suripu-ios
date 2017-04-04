//
//  HEMAnswerCell.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMSingleResponseCell.h"

@implementation HEMSingleResponseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView* selectedView = [[UIView alloc] initWithFrame:[[self contentView] bounds]];
    [selectedView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self setSelectedBackgroundView:selectedView];
    [self applyStyle];
}

@end
