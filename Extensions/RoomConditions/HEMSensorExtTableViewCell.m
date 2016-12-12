//
//  HEMTodayVIewCell.m
//  Sense
//
//  Created by Delisa Mason on 11/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSensorExtTableViewCell.h"

@interface HEMSensorExtTableViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorIconLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelTrailingConstraint;

@end

@implementation HEMSensorExtTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (![[self sensorIconLeadingConstraint] respondsToSelector:@selector(firstAnchor)]) {
        // is iOS 9
        [[self sensorIconLeadingConstraint] setConstant:0.0f];
        [[self valueLabelTrailingConstraint] setConstant:0.0f];
    }
}

@end
