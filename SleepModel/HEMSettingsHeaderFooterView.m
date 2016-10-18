//
//  HEMSettingsHeaderFooterView.m
//  Sense
//
//  Created by Jimmy Lu on 11/16/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

#import "HEMSettingsHeaderFooterView.h"

CGFloat const HEMSettingsHeaderFooterHeight = 8.0f;
CGFloat const HEMSettingsHeaderFooterSectionHeight = 12.0f;
CGFloat const HEMSettingsHeaderFooterBorderHeight = 0.5f;
CGFloat const HEMSettingsHeaderFooterHeightWithTitle = 25.0f;

static CGFloat const HEMSettingsHeaderFooterTitleMargins = 24.0f;

@interface HEMSettingsHeaderFooterView()

@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UIView* topBorder;
@property (nonatomic, weak) UIView* bottomBorder;

@end

@implementation HEMSettingsHeaderFooterView

- (instancetype)initWithTopBorder:(BOOL)topBorder bottomBorder:(BOOL)bottomBorder {
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsHeaderFooterHeight;
    
    self = [super initWithFrame:frame];
    if (self) {
        [self addTopBorder:topBorder bottomBorder:bottomBorder];
    }
    return self;
}

- (UIView*)borderViewAtYOrigin:(CGFloat)yOrigin {
    CGRect borderFrame = CGRectZero;
    borderFrame.origin.y = yOrigin;
    borderFrame.size.height = HEMSettingsHeaderFooterBorderHeight;
    UIView* border = [[UIView alloc] initWithFrame:borderFrame];
    [border setBackgroundColor:[UIColor separatorColor]];
    [border setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    return border;
}
     
- (void)addTopBorder:(BOOL)topBoarder bottomBorder:(BOOL)bottomBorder {
    if (topBoarder) {
        UIView* tBorder = [self borderViewAtYOrigin:0.0f];
        [self addSubview:tBorder];
        [self setTopBorder:tBorder];
    }
    
    if (bottomBorder) {
        CGFloat y = MAX(0.0f, CGRectGetHeight([self bounds]) - HEMSettingsHeaderFooterBorderHeight);
        UIView* bBorder = [self borderViewAtYOrigin:y];
        [self addSubview:bBorder];
        [self setBottomBorder:bBorder];
    }
}

- (void)setTitle:(NSString*)title {
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont settingsSectionHeaderFont],
                                 NSForegroundColorAttributeName : [UIColor grey4]};
    NSAttributedString* attrTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    [self setAttributedTitle:attrTitle];
}

- (void)setAttributedTitle:(NSAttributedString*)attributedTitle {
    if (![self titleLabel]) {
        // set default
        [self setTitleInsets:UIEdgeInsetsMake(0.0f,
                                              HEMSettingsHeaderFooterTitleMargins,
                                              0.0f,
                                              HEMSettingsHeaderFooterTitleMargins)];
        
        UILabel* label = [UILabel new];
        [label setNumberOfLines:0];
        [label setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:label];
        [self setTitleLabel:label];
    }
    
    [[self titleLabel] setAttributedText:attributedTitle];
}

- (void)layoutSubviews {
    if ([self titleLabel]) {
        CGFloat horzMargins = [self titleInsets].left + [self titleInsets].right;;
        CGFloat width = CGRectGetWidth([self bounds]) - horzMargins;
        CGRect frame = [[self titleLabel] frame];
        frame.size.width = width;
        frame.origin.x = [self titleInsets].left;
        frame.origin.y = [self titleInsets].top;
        
        if ([self adjustBasedOnTitle]) {
            CGSize constraint = CGSizeMake(width, MAXFLOAT);
            CGSize textSize = [[self titleLabel] sizeThatFits:constraint];
            frame.size.height = textSize.height;
        } else {
            frame.size.height = HEMSettingsHeaderFooterHeightWithTitle;
        }
        
        [[self titleLabel] setFrame:frame];
        
        CGRect myFrame = [self frame];
        myFrame.size.height = CGRectGetMaxY(frame) + [self titleInsets].bottom;
        [self setFrame:myFrame];
    }
    
    if ([self bottomBorder]) {
        CGRect borderFrame = [[self bottomBorder] frame];
        borderFrame.origin.y = CGRectGetHeight([self bounds]) - HEMSettingsHeaderFooterBorderHeight;
        [[self bottomBorder] setFrame:borderFrame];
    }
}

@end
