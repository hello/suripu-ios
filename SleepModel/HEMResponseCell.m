//
//  HEMResponseCell.m
//  Sense
//
//  Created by Jimmy Lu on 12/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMResponseCell.h"

@implementation HEMResponseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyStyle];
}

- (void)updateConstraints {
    [super updateConstraints];
    [[self separatorHeightConstraint] setConstant:0.5f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    Class aClass = [HEMResponseCell class];
    UIColor* textColor = [SenseStyle colorWithAClass:aClass property:ThemePropertyTextColor];
    UIColor* highlightedColor = [SenseStyle colorWithAClass:aClass property:ThemePropertyTextHighlightedColor];
    UIColor* color = selected ? textColor : highlightedColor;
    [[self answerLabel] setTextColor:color];
}

- (void)applyStyle {
    [super applyStyle];
    
    Class aClass = [HEMResponseCell class];
    UIColor* textColor = [SenseStyle colorWithAClass:aClass property:ThemePropertyTextHighlightedColor];
    UIFont* textFont = [SenseStyle fontWithAClass:aClass property:ThemePropertyTextFont];
    UIColor* separatorColor = [SenseStyle colorWithAClass:aClass property:ThemePropertySeparatorColor];
    
    [[self separator] setBackgroundColor:separatorColor];
    [[self answerLabel] setFont:textFont];
    [[self answerLabel] setTextColor:textColor];
    [[self answerLabel] setTextAlignment:NSTextAlignmentCenter];
}

@end
