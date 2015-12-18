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
#import "HEMAnimationUtils.h"

CGFloat const HEMDeviceActionCellHeight = 56.0f;

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
        UIImage* loaderImage = [UIImage imageNamed:@"settingsLoader"];
        CGPoint iconCenter = [[self iconView] center];
        CGRect indicatorFrame = CGRectZero;
        indicatorFrame.origin.x = iconCenter.x - (loaderImage.size.width / 2.0f);
        indicatorFrame.origin.y = iconCenter.y - (loaderImage.size.height / 2.0f);
        indicatorFrame.size = loaderImage.size;
        [self setIndicator:[[HEMActivityIndicatorView alloc] initWithImage:loaderImage
                                                                  andFrame:indicatorFrame]];
        
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
