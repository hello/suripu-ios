//
//  HEMDeviceInfoTableViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/1/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMDeviceInfoTableViewCell.h"

static CGFloat const kHEMDeviceInfoPadding = 15.0f;
static CGFloat const kHEMDeviceInfoHeight = 20.0f;

@implementation HEMDeviceInfoTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize constraint = [[self detailTextLabel] bounds].size;
    constraint.width = MAXFLOAT;
    CGSize detailSize = [[self detailTextLabel] sizeThatFits:constraint];
    CGRect detailFrame = [[self detailTextLabel] frame];
    detailFrame.size.width = detailSize.width;
    detailFrame.origin.x = CGRectGetWidth([[self contentView] bounds])
                            -detailSize.width
                            - kHEMDeviceInfoPadding;
    detailFrame.size.height = kHEMDeviceInfoHeight;
    [[self detailTextLabel] setFrame:detailFrame];
}

@end
