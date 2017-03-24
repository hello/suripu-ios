//
//  HEMActionSheetOptionCell.m
//  Sense
//
//  Created by Jimmy Lu on 4/22/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMActionSheetOptionCell.h"
#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"

static CGFloat const HEMActionSheetOptionLabelSpacing = 4.0f;
static CGFloat const HEMActionSheetOptionVertMargin = 20.0f;
static CGFloat const HEMActionSheetOptionHorzMargin = 24.0f;
static CGFloat const HEMActionSheetOptionTitleToIconSpacing = 20.0f;
static CGFloat const HEMActionSheetOptionMinHeight = 72.0f;

@interface HEMActionSheetOptionCell()

@property (weak, nonatomic) IBOutlet UILabel *optionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *optionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;

@end

@implementation HEMActionSheetOptionCell

+ (CGFloat)heightWithTitle:(NSString*)title
               description:(NSString *)description
                  maxWidth:(CGFloat)width {
    
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    CGFloat height = HEMActionSheetOptionVertMargin;
    CGFloat textWidth = width - (2 * HEMActionSheetOptionHorzMargin);
    
    height += [title heightBoundedByWidth:textWidth usingFont:titleFont];
    
    if ([description length] > 0) {
        height += HEMActionSheetOptionLabelSpacing;
        
        UIFont* descFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
        height += [description heightBoundedByWidth:textWidth usingFont:descFont];
    }
    
    height += HEMActionSheetOptionVertMargin;
    
    return MAX(HEMActionSheetOptionMinHeight, ceilf(height));
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIColor* bgColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyBackgroundColor];
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    UIColor* titleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor];
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIColor* color = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    [self setBackgroundColor:bgColor];
    [[self optionTitleLabel] setFont:titleFont];
    [[self optionTitleLabel] setTextColor:titleColor];
    [[self optionDescriptionLabel] setFont:font];
    [[self optionDescriptionLabel] setTextColor:color];
    [[self optionDescriptionLabel] setBackgroundColor:bgColor];
    [[self optionTitleLabel] setBackgroundColor:bgColor];
    [self configureSelectedBackground];
}

- (void)prepareForReuse {
    [[self optionTitleLabel] setText:nil];
    [[self optionDescriptionLabel] setText:nil];
    [[self iconImageView] setImage:nil];
    [[self imageViewWidth] setConstant:0.0f];
}

- (void)updateConstraints {
    CGSize imageSize = [[self iconImageView] image].size;
    CGFloat titleLeftMargin = 0.0f;
    
    if (imageSize.width > 0) {
        titleLeftMargin = HEMActionSheetOptionTitleToIconSpacing;
    }
    
    if ([[[self optionDescriptionLabel] text] length] == 0) {
        CGFloat bHeight = CGRectGetHeight([self bounds]);
        [[self titleHeightConstraint] setConstant:bHeight];
        [[self titleTopConstraint] setConstant:0.0f];
    }
    
    [[self imageViewWidth] setConstant:imageSize.width];
    [[self titleLeadingConstraint] setConstant:titleLeftMargin];
    [super updateConstraints];
}

- (void)setOptionTitle:(NSString*)title
             withColor:(UIColor*)titleColor
                  icon:(UIImage*)icon
           description:(NSString*)description {
    [self setOptionTitle:title
               withColor:titleColor
                    icon:icon
             description:description
           textAlignment:NSTextAlignmentLeft];
}

- (void)setOptionTitle:(NSString*)title
             withColor:(UIColor*)titleColor
                  icon:(UIImage*)icon
           description:(NSString*)description
         textAlignment:(NSTextAlignment)alignment {
    [[self optionTitleLabel] setText:title];
    [[self optionTitleLabel] setTextColor:titleColor];
    [[self optionTitleLabel] setTextAlignment:alignment];
    [[self iconImageView] setImage:icon];
    [[self optionDescriptionLabel] setText:description];
    [[self optionDescriptionLabel] setTextAlignment:alignment];
    
    UIFont* titleFont = [[self optionTitleLabel] font];
    CGRect titleFrame = [[self optionTitleLabel] frame];
    CGFloat titleWidth = CGRectGetWidth(titleFrame);
    titleFrame.size.height = [title heightBoundedByWidth:titleWidth usingFont:titleFont];
    [[self optionTitleLabel] setFrame:titleFrame];
    
    [self setNeedsUpdateConstraints];
}

- (void)configureSelectedBackground {
    UIView* view = [[UIView alloc] initWithFrame:[[self contentView] bounds]];
    UIColor* bgColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyBackgroundHighlightedColor];
    [view setBackgroundColor:bgColor];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self setSelectedBackgroundView:view];
}

@end
