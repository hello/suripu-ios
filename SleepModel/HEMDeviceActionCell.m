//
//  HEMDeviceActionCell.m
//  Sense
//
//  Created by Jimmy Lu on 11/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "UIColor+HEMStyle.h"

#import "HEMDeviceActionCell.h"
#import "HEMActivityIndicatorView.h"
#import "HelloStyleKit.h"
#import "HEMAnimationUtils.h"

CGFloat const HEMDeviceActionCellHeight = 56.0f;
static CGFloat const HEMDeviceActionActivitySize = 20.0f;

@interface HEMDeviceActionCell()

@property (nonnull, strong) HEMActivityIndicatorView* indicator;

@end

@implementation HEMDeviceActionCell

- (void)awakeFromNib {
    [self setBackgroundColor:[UIColor whiteColor]];
    [[self topSeparatorView] setBackgroundColor:[UIColor separatorColor]];
    [[self separatorView] setBackgroundColor:[UIColor separatorColor]];
}

- (void)prepareForReuse {
    [[self topSeparatorView] setHidden:YES];
}

- (void)setEnabled:(BOOL)enabled {
    [self setUserInteractionEnabled:enabled];
    
    CGFloat alpha = enabled ? 1.0f : 0.2f;
    [[self iconView] setAlpha:alpha];
    [[self textLabel] setAlpha:alpha];
}

- (void)showActivity:(BOOL)show withText:(NSString*)text {
    [[self textLabel] setText:text];
    
    if (show) {
        CGPoint iconCenter = [[self iconView] center];
        CGRect indicatorFrame = CGRectZero;
        indicatorFrame.origin.x = iconCenter.x - (HEMDeviceActionActivitySize / 2.0f);
        indicatorFrame.origin.y = iconCenter.y - (HEMDeviceActionActivitySize / 2.0f);
        indicatorFrame.size = CGSizeMake(HEMDeviceActionActivitySize, HEMDeviceActionActivitySize);
        [self setIndicator:[[HEMActivityIndicatorView alloc] initWithFrame:indicatorFrame]];
        
        [[self iconView] setHidden:YES];
        [[self iconView] setTransform:CGAffineTransformMakeScale(0.1f, 0.1f)];
        [[self contentView] insertSubview:[self indicator] aboveSubview:[self iconView]];
        
        [[self indicator] start];
    } else {
        [[self indicator] stop];
        [[self iconView] setHidden:NO];
        [HEMAnimationUtils grow:[self iconView] completion:nil];
    }
}

@end
