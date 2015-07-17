//
//  HEMResponseCell.m
//  Sense
//
//  Created by Jimmy Lu on 12/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMResponseCell.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

@implementation HEMResponseCell

- (void)awakeFromNib {
    [self setBackgroundColor:[UIColor clearColor]];
    
    [[self answerLabel] setBackgroundColor:[UIColor clearColor]];
    [[self answerLabel] setTextColor:[UIColor senseBlueColor]];
    [[self answerLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self answerLabel] setFont:[UIFont questionAnswerFont]];
    
    [[self separator] setBackgroundColor:[[UIColor senseBlueColor]
                                          colorWithAlphaComponent:0.5f]];
}

- (void)updateConstraints {
    [super updateConstraints];
    [[self separatorHeightConstraint] setConstant:0.5f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    UIColor* color
        = selected
        ? [UIColor questionAnswerSelectedTextColor]
        : [UIColor senseBlueColor];
    [[self answerLabel] setTextColor:color];
}

@end
