//
//  HEMSettingsTableViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/5/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMSettingsTableViewCell.h"
#import "HEMMathUtil.h"
#import "HelloStyleKit.h"

CGFloat const HEMSettingsCellTableMargin = 20.0f;

static CGFloat const HEMSettingsCellCornerRadius = 2.0f;
static CGFloat const HEMSettingsCellSeparatorSize = 0.5f;
static CGFloat const HEMSettingsCellMargins = 16.0f;
static CGFloat const HEMSettingsCellShadowOpacity = 0.5f;

@interface HEMSettingsTableViewCell()

@property (nonatomic, weak) CAShapeLayer* contentLayer;
@property (nonatomic, weak) UIView* separator;
@property (nonatomic, strong) UIActivityIndicatorView* activityView;

@end

@implementation HEMSettingsTableViewCell

- (void)awakeFromNib {
    [self setBackgroundColor:[UIColor clearColor]];
    [[self contentView] setBackgroundColor:[UIColor clearColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self addContentLayer];
    [self addSeparator];
    
    [[self titleLabel] setFont:[UIFont settingsTableCellFont]];
    [[self titleLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[self titleLabel] setBackgroundColor:[UIColor clearColor]];
    
    [[self valueLabel] setFont:[UIFont settingsTableCellDetailFont]];
    [[self valueLabel] setTextColor:[HelloStyleKit settingsValueTextColor]];
    [[self valueLabel] setBackgroundColor:[UIColor clearColor]];
    [[self valueLabel] setTextAlignment:NSTextAlignmentRight];
}

- (CGRect)layerFrame {
    CGRect frame = [self bounds];
    frame.origin.x = HEMSettingsCellMargins;
    frame.size.width = CGRectGetWidth(frame) - (2*HEMSettingsCellMargins);
    return frame;
}

- (void)addContentLayer {
    NSShadow* shadow = [HelloStyleKit backViewCardShadow];
    
    CAShapeLayer * layer = [CAShapeLayer layer];
    [layer setFillColor:[[UIColor whiteColor] CGColor]];
    [layer setShadowOffset:[shadow shadowOffset]];
    [layer setShadowRadius:[shadow shadowBlurRadius]];
    [layer setShadowOpacity:HEMSettingsCellShadowOpacity];
    [layer setShadowColor:[[shadow shadowColor] CGColor]];
    
    [self setContentLayer:layer];
    [[self layer] insertSublayer:layer atIndex:0];
}

- (void)addSeparator {
    CGFloat x = CGRectGetMinX([[self titleLabel] frame]);
    CGRect separatorFrame = {
        x,
        CGRectGetHeight([self bounds])-HEMSettingsCellSeparatorSize,
        CGRectGetWidth([self bounds])-HEMSettingsCellMargins - x,
        HEMSettingsCellSeparatorSize
    };
    UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
    [separator setBackgroundColor:[HelloStyleKit separatorColor]];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                   | UIViewAutoresizingFlexibleTopMargin];
    [[self contentView] addSubview:separator];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSShadow* shadow = [HelloStyleKit backViewCardShadow];
    // update the shadow based on updated bounds, if resized
    CGRect shadowInset = CGRectInset([self layerFrame], 0.0f, [shadow shadowBlurRadius]);
    [[self contentLayer] setShadowPath:[[UIBezierPath bezierPathWithRect:shadowInset] CGPath]];
}

- (void)roundContentLayerCorners:(UIRectCorner)corners {
    CGSize cornerRadii = CGSizeMake(HEMSettingsCellCornerRadius, HEMSettingsCellCornerRadius);
    [[self contentLayer] setPath:[[UIBezierPath bezierPathWithRoundedRect:[self layerFrame]
                                                        byRoundingCorners:corners
                                                              cornerRadii:cornerRadii] CGPath]];
}

- (void)showTopCorners {
    [self roundContentLayerCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    [[self separator] setHidden:NO];
}

- (void)showBottomCorners {
    [self roundContentLayerCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight];
    [[self separator] setHidden:YES];
}

- (void)showNoCorners {
    [[self contentLayer] setPath:[[UIBezierPath bezierPathWithRect:[self layerFrame]] CGPath]];
    [[self separator] setHidden:NO];
}

- (void)showTopAndBottomCorners {
    [self roundContentLayerCorners:UIRectCornerAllCorners];
    [[self separator] setHidden:YES];
}

@end
