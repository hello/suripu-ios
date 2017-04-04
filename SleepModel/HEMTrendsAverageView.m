//
//  HEMTrendsAverageView.m
//  Sense
//
//  Created by Jimmy Lu on 2/4/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMTrendsAverageView.h"

@implementation HEMTrendsAverageView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyStyle];
}

- (void)applyStyle {
    [super applyFillStyle];
    
    UIColor* titleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor];
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    [[self average1TitleLabel] setFont:titleFont];
    [[self average1TitleLabel] setTextColor:titleColor];
    [[self average2TitleLabel] setFont:titleFont];
    [[self average2TitleLabel] setTextColor:titleColor];
    [[self average3TitleLabel] setFont:titleFont];
    [[self average3TitleLabel] setTextColor:titleColor];
}


@end
