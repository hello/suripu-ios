//
//  HEMDeviceActionCell.m
//  Sense
//
//  Created by Jimmy Lu on 11/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "Sense-Swift.h"

#import "HEMDeviceActionCell.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAnimationUtils.h"

CGFloat const HEMDeviceActionCellHeight = 56.0f;

@interface HEMDeviceActionCell()

@property (nonnull, strong) HEMActivityIndicatorView* indicator;
@property (nonnull, strong) UIView* disabledOverlay;

@end

@implementation HEMDeviceActionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyStyle];
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

- (void)applyStyle {
    [[self separatorView] applySeparatorStyle];
    [[self topSeparatorView] applySeparatorStyle];

    UIColor* tintColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTintColor];
    UIColor* backgroundColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyBackgroundColor];
    UIColor* textColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIFont* textFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    [[self textLabel] setTextColor:textColor];
    [[self textLabel] setFont:textFont];
    [[self iconView] setTintColor:tintColor];
    [self setBackgroundColor:backgroundColor];
}

@end
