//
//  HEMActionSheetOptionCell.m
//  Sense
//
//  Created by Jimmy Lu on 4/22/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HelloStyleKit.h"
#import "HEMActionSheetOptionCell.h"

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

@end

@implementation HEMActionSheetOptionCell

+ (CGFloat)heightWithTitle:(NSString*)title
               description:(NSString *)description
                  maxWidth:(CGFloat)width {
    
    CGFloat height = HEMActionSheetOptionVertMargin;
    
    UIFont* titleFont = [UIFont actionSheetOptionTitleFont];
    height += [self heightForText:title usingFont:titleFont constrainedToWidth:width];
    
    if ([description length] > 0) {
        height += HEMActionSheetOptionLabelSpacing;
        
        UIFont* descFont = [UIFont actionSheetOptionDescriptionFont];
        height += [self heightForText:description usingFont:descFont constrainedToWidth:width];
    }
    
    height += HEMActionSheetOptionVertMargin;
    
    return MAX(HEMActionSheetOptionMinHeight, ceilf(height));
}

+ (CGFloat)heightForText:(NSString*)text usingFont:(UIFont*)font constrainedToWidth:(CGFloat)width {
    NSDictionary* attributes = @{NSFontAttributeName : font};
    CGSize constraint = CGSizeMake(width-(2*HEMActionSheetOptionHorzMargin), MAXFLOAT);
    return [text boundingRectWithSize:constraint
                              options:NSStringDrawingUsesFontLeading
                                      |NSStringDrawingUsesLineFragmentOrigin
                           attributes:attributes
                              context:nil].size.height;
}

- (void)awakeFromNib {
    [[self optionTitleLabel] setFont:[UIFont actionSheetOptionTitleFont]];
    [[self optionDescriptionLabel] setFont:[UIFont actionSheetOptionDescriptionFont]];
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
        CGFloat titleHeight = CGRectGetHeight([[self optionTitleLabel] bounds]);
        CGFloat titleTopMargin
            = ((CGRectGetHeight([self bounds]) - titleHeight)/2)
            + [[[self optionTitleLabel] font] descender];
        [[self titleTopConstraint] setConstant:titleTopMargin];
    }
    
    [[self imageViewWidth] setConstant:imageSize.width];
    [[self titleLeadingConstraint] setConstant:titleLeftMargin];
    [super updateConstraints];
}

- (void)setOptionTitle:(NSString*)title
             withColor:(UIColor*)titleColor
                  icon:(UIImage*)icon
           description:(NSString*)description {
    
    [[self optionTitleLabel] setText:title];
    [[self optionTitleLabel] setTextColor:titleColor];
    [[self iconImageView] setImage:icon];
    [[self optionDescriptionLabel] setText:description];
    [self setNeedsUpdateConstraints];
}

- (void)configureSelectedBackground {
    UIView* view = [[UIView alloc] initWithFrame:[[self contentView] bounds]];
    [view setBackgroundColor:[HelloStyleKit actionSheetSelectedColor]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self setSelectedBackgroundView:view];
}

@end
