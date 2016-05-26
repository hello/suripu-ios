//
//  HEMSettingsTableViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/5/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMStyle.h"

#import "HEMSettingsTableViewCell.h"
#import "HEMMathUtil.h"

CGFloat const HEMSettingsCellTableMargin = 16.0f;

static CGFloat const HEMSettingsCellCornerRadius = 2.0f;
static CGFloat const HEMSettingsCellSeparatorSize = 0.5f;
static CGFloat const HEMSettingsCellMargins = 12.0f;

@interface HEMSettingsTableViewCell ()

@property (nonatomic, weak) CAShapeLayer *contentLayer;
@property (nonatomic, weak) CAShapeLayer *borderLayer;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, weak) UIImageView* somethingNewIndicator;
@end

@implementation HEMSettingsTableViewCell

- (void)awakeFromNib {
    [self setBackgroundColor:[UIColor clearColor]];
    [[self contentView] setBackgroundColor:[UIColor clearColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    [self addContentLayer];
    [self addSeparator];

    [[self titleLabel] setFont:[UIFont settingsTableCellFont]];
    [[self titleLabel] setTextColor:[UIColor textColor]];
    [[self titleLabel] setBackgroundColor:[UIColor clearColor]];

    [[self valueLabel] setFont:[UIFont settingsTableCellDetailFont]];
    [[self valueLabel] setTextColor:[UIColor detailTextColor]];
    [[self valueLabel] setBackgroundColor:[UIColor clearColor]];
    [[self valueLabel] setTextAlignment:NSTextAlignmentRight];
}

- (CGRect)layerFrame {
    CGRect frame = [self bounds];
    frame.origin.x = HEMSettingsCellMargins;
    frame.size.width = CGRectGetWidth(frame) - (2 * HEMSettingsCellMargins);
    return frame;
}

- (void)addContentLayer {
    CAShapeLayer *layer = [CAShapeLayer layer];
    [layer setFillColor:[[UIColor whiteColor] CGColor]];

    [self setContentLayer:layer];
    [[self layer] insertSublayer:layer atIndex:0];
    CAShapeLayer *borderLyer = [CAShapeLayer layer];
    [borderLyer setFillColor:[[UIColor cardBorderColor] CGColor]];
    self.borderLayer = borderLyer;
    [self.layer insertSublayer:borderLyer atIndex:0];
}

- (CGFloat)separatorIndentation {
    return CGRectGetMinX([[self titleLabel] frame]);
}

- (void)relayoutSeparator {
    CGFloat x = [self separatorIndentation];
    CGRect separatorFrame = CGRectZero;
    separatorFrame.origin.x = x;
    separatorFrame.origin.y = CGRectGetHeight([self bounds]) - HEMSettingsCellSeparatorSize;
    separatorFrame.size.width = CGRectGetWidth([self bounds]) - HEMSettingsCellMargins - x;
    separatorFrame.size.height = HEMSettingsCellSeparatorSize;
    [[self separator] setFrame:separatorFrame];
}

- (void)addSeparator {
    if (![self separator]) {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
        [separator setBackgroundColor:[UIColor separatorColor]];
        [self setSeparator:separator];
        [[self contentView] addSubview:separator];
    }
    
    [[self separator] setBackgroundColor:[UIColor separatorColor]];
}

- (void)prepareForReuse {
    [[self contentLayer] setHidden:NO];
    [[self separator] setHidden:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self relayoutSeparator];
}

- (void)roundContentLayerCorners:(UIRectCorner)corners {
    CGSize cornerRadii = CGSizeMake(HEMSettingsCellCornerRadius, HEMSettingsCellCornerRadius);
    CGRect contentFrame = [self layerFrame];
    CGPathRef contentPath = [
        [UIBezierPath bezierPathWithRoundedRect:contentFrame byRoundingCorners:corners cornerRadii:cornerRadii] CGPath];
    [[self contentLayer] setPath:contentPath];
    CGRect borderFrame = CGRectInset(contentFrame, -1.f, 0);
    if ((corners & (UIRectCornerTopLeft | UIRectCornerTopRight)) != 0) {
        borderFrame.origin.y -= 1;
        borderFrame.size.height += 1;
    }
    if ((corners & (UIRectCornerBottomLeft | UIRectCornerBottomRight)) != 0) {
        borderFrame.size.height += 1;
    }
    CGPathRef borderPath =
        [[UIBezierPath bezierPathWithRoundedRect:borderFrame byRoundingCorners:corners cornerRadii:cornerRadii] CGPath];
    [[self borderLayer] setPath:borderPath];
}

- (void)showNewIndicator:(BOOL)show {
    if (![self somethingNewIndicator]) {
        UIImage* icon = [UIImage imageNamed:@"unreadIndicator"];
        CGRect iconFrame = CGRectZero;
        iconFrame.size = icon.size;
        iconFrame.origin.y = (CGRectGetHeight([self bounds]) - icon.size.height) / 2.0f;
        iconFrame.origin.x = HEMSettingsCellMargins - (icon.size.width / 2.0f);
        
        UIImageView* iconView = [[UIImageView alloc] initWithFrame:iconFrame];
        [iconView setImage:icon];
        
        [self setSomethingNewIndicator:iconView];
        [[self contentView] addSubview:iconView];
    }
    [[self somethingNewIndicator] setHidden:!show];
}

- (void)showShadow:(BOOL)isVisible {
    CALayer *layer = [self.layer.sublayers firstObject];
    if (isVisible) {
        NSShadow *shadow = [NSShadow shadowForBackViewCards];
        layer.shadowOffset = shadow.shadowOffset;
        layer.shadowOpacity = 0.3f;
        layer.shadowRadius = shadow.shadowBlurRadius;
        layer.shadowColor = [shadow.shadowColor CGColor];
        layer.borderColor = [[UIColor borderColor] CGColor];
    } else { layer.shadowOpacity = 0; }
}

- (void)showTopCorners {
    [self roundContentLayerCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self showShadow:NO];
    [[self separator] setHidden:NO];
}

- (void)showBottomCorners {
    [self roundContentLayerCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
    [self showShadow:YES];
    [[self separator] setHidden:YES];
}

- (void)showNoCorners {
    [self roundContentLayerCorners:0];
    [self showShadow:NO];
    [[self separator] setHidden:NO];
}

- (void)showTopAndBottomCorners {
    [self roundContentLayerCorners:UIRectCornerAllCorners];
    [self showShadow:YES];
    [[self separator] setHidden:YES];
}

@end
