//
//  HEMEventAdjustConfirmationView.m
//  Sense
//
//  Created by Jimmy Lu on 6/26/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "NSString+HEMUtils.h"
#import "UIFont+HEMStyle.h"

#import "HEMEventAdjustConfirmationView.h"
#import "HelloStyleKit.h"

static CGFloat const HEMAdjustConfirmIconSize = 40.0f;
static CGFloat const HEMAdjustConfirmVertPadding = 25.0f;
static CGFloat const HEMAdjustConfirmHorzPadding = 20.0f;
static CGFloat const HEMAdjustConfirmImageSpacing = 17.0f;
static CGFloat const HEMAdjustConfirmTextSpacing = 10.0f;

@interface HEMEventAdjustConfirmationView()

@property (nonatomic, weak) UIImageView* iconView;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* subtitleLabel;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

@end

@implementation HEMEventAdjustConfirmationView

- (instancetype)initWithTitle:(NSString*)title
                     subtitle:(NSString*)subtitle
                        frame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _title = [title copy];
        _subtitle = [subtitle copy];
        [self configureView];
    }
    return self;
}

- (void)configureView {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self addIcon];
    [self addTitleLabel];
    [self addSubtitleLabel];
}

- (void)addIcon {
    UIImage* confirmIcon = [HelloStyleKit check];
    
    CGFloat bWidth = CGRectGetWidth([self bounds]);
    CGRect confirmIconViewFrame = CGRectZero;
    confirmIconViewFrame.origin.y = HEMAdjustConfirmVertPadding;
    confirmIconViewFrame.origin.x = (bWidth - HEMAdjustConfirmIconSize)/2;
    confirmIconViewFrame.size = CGSizeMake(HEMAdjustConfirmIconSize, HEMAdjustConfirmIconSize);
    
    UIImageView* confirmIconView = [[UIImageView alloc] initWithImage:confirmIcon];
    [confirmIconView setFrame:confirmIconViewFrame];
    
    [self setIconView:confirmIconView];
    [self addSubview:confirmIconView];
}

- (UILabel*)textLabelWithYOrigin:(CGFloat)yOrigin andText:(NSString*)text withFont:(UIFont*)font {
    CGFloat bWidth = CGRectGetWidth([self bounds]);
    CGFloat constraintWidth = bWidth - (HEMAdjustConfirmHorzPadding * 2);
    CGFloat textHeight = [text heightBoundedByWidth:constraintWidth usingFont:font];
    
    CGRect labelFrame = CGRectZero;
    labelFrame.origin.x = HEMAdjustConfirmHorzPadding;
    labelFrame.origin.y = yOrigin;
    labelFrame.size.width = constraintWidth;
    labelFrame.size.height = textHeight;
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setFont:font];
    [label setText:text];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:0];
    
    return label;
}

- (void)addTitleLabel {
    CGFloat y = CGRectGetMaxY([[self iconView] frame]) + HEMAdjustConfirmImageSpacing;
    UIFont* titleFont = [UIFont timelineActionConfirmationTitleFont];
    UILabel* titleLabel = [self textLabelWithYOrigin:y andText:[self title] withFont:titleFont];
    [self setTitleLabel:titleLabel];
    [self addSubview:titleLabel];
}

- (void)addSubtitleLabel {
    if ([self subtitle]) {
        CGFloat y = CGRectGetMaxY([[self titleLabel] frame]) + HEMAdjustConfirmTextSpacing;
        UIFont* subtitleFont = [UIFont timelineActionConfirmationSubtitleFont];
        UILabel* subtitleLabel = [self textLabelWithYOrigin:y andText:[self subtitle] withFont:subtitleFont];
        [subtitleLabel setTextColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
        [self setSubtitleLabel:subtitleLabel];
        [self addSubview:subtitleLabel];
    }
}

- (void)setAlpha:(CGFloat)alpha {
    if (alpha == 0.0f) {
        [[self iconView] setTransform:CGAffineTransformMakeScale(0.1f, 0.1f)];
    } else if (alpha < 1.0f) {
        [[self iconView] setTransform:CGAffineTransformMakeScale(alpha, alpha)];
    } else {
        UIViewAnimationOptions options = UIViewAnimationOptionOverrideInheritedDuration|UIViewAnimationOptionOverrideInheritedCurve;
        [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:options animations:^{
            [[self iconView] setTransform:CGAffineTransformIdentity];
        } completion:nil];
    }
    [[self iconView] setAlpha:alpha];
    [[self titleLabel] setAlpha:alpha];
    [[self subtitleLabel] setAlpha:alpha];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat bHeight = CGRectGetHeight([self bounds]);
    CGFloat iconHeight = CGRectGetHeight([[self iconView] bounds]);
    CGFloat titleHeight = CGRectGetHeight([[self titleLabel] bounds]);
    CGFloat subtitleHeight = CGRectGetHeight([[self subtitleLabel] bounds]);
    CGFloat contentHeight
        = iconHeight
        + HEMAdjustConfirmImageSpacing
        + titleHeight
        + HEMAdjustConfirmTextSpacing
        + subtitleHeight;
    CGFloat vertPadding = MAX(HEMAdjustConfirmVertPadding, ceilf((bHeight - contentHeight)/2));
    
    CGRect iconFrame = [[self iconView] frame];
    iconFrame.origin.y = vertPadding;
    [[self iconView] setFrame:iconFrame];
    
    CGRect titleFrame = [[self titleLabel] frame];
    titleFrame.origin.y = CGRectGetMaxY(iconFrame) + HEMAdjustConfirmImageSpacing;
    [[self titleLabel] setFrame:titleFrame];
    
    if ([self subtitleLabel]) {
        CGRect subtitleFrame = [[self subtitleLabel] frame];
        subtitleFrame.origin.y = CGRectGetMaxY(titleFrame) + HEMAdjustConfirmTextSpacing;
        [[self subtitleLabel] setFrame:subtitleFrame];
    }
}

@end
