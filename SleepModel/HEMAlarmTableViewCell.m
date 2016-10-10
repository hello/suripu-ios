//
//  HEMAlarmTableViewCell.m
//  Sense
//
//  Created by Delisa Mason on 12/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMAlarmTableViewCell.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const kHEMAlarmCellFadeDuration = 0.5f;

@implementation HEMAlarmTableViewCell

- (void)awakeFromNib {
    [[self activityView] setUserInteractionEnabled:NO];
    [[self activityView] setIndicatorImage:[UIImage imageNamed:@"smallLoaderGray"]];
}

- (void)showActivity:(BOOL)show {
    [[self smartSwitch] setHidden:show];
    [[self detailLabel] setHidden:show];
    [[self accessoryView] setHidden:show];
    [[self detailTextLabel] setHidden:show];
    [[self errorIcon] setHidden:show];
    
    if (show) {
        [[self activityView] start];
        [[self activityView] setHidden:NO];
        [[self smartSwitch] setAlpha:0.0f];
        [[self detailLabel] setAlpha:0.0f];
        [[self accessoryView] setAlpha:0.0f];
        [[self detailTextLabel] setAlpha:0.0f];
        
    } else {
        [[self activityView] stop];
        [[self activityView] setHidden:YES];
        
        [UIView animateWithDuration:kHEMAlarmCellFadeDuration animations:^{
            [[self smartSwitch] setAlpha:1.0f];
            [[self detailLabel] setAlpha:1.0f];
            [[self accessoryView] setAlpha:1.0f];
            [[self detailTextLabel] setAlpha:1.0f];
        }];
    }
}

@end
