//
//  HEMAlarmTableViewCell.m
//  Sense
//
//  Created by Delisa Mason on 12/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"

#import "HEMAlarmTableViewCell.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const kHEMAlarmCellFadeDuration = 0.5f;

@implementation HEMAlarmTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIImage* warningImage = [SenseStyle imageWithGroup:GroupWarningIcon
                                              property:ThemePropertyIconImage];
    UIColor* warningTint = [SenseStyle colorWithGroup:GroupWarningIcon
                                             property:ThemePropertyTintColor];
    [[self errorIcon] setImage:[warningImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [[self errorIcon] setTintColor:warningTint];
    [[self activityView] setUserInteractionEnabled:NO];
    [[self activityView] setIndicatorImage:[UIImage imageNamed:@"settingsLoader"]];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    [self setSelectedBackgroundView:[UIView new]];
    [self applyStyle];
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

- (void)applyStyle {
    [super applyStyle];
    
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIColor* titleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    [[self titleLabel] setFont:titleFont];
    [[self titleLabel] setTextColor:titleColor];

    UIFont* detailFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    [[self detailLabel] setFont:detailFont];
    
    if ([[self detailLabel] isHighlighted]) {
        [[self detailLabel] setTextColor:[SenseStyle colorWithAClass:[self class] property:ThemePropertyLinkColor]];
    } else {
        [[self detailLabel] setTextColor:[SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor]];
    }

    [[self iconView] setTintColor:titleColor];
}

@end
