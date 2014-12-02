//
//  HEMAnswerCell.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMAnswerCell.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

@interface HEMAnswerCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@end

@implementation HEMAnswerCell

- (void)awakeFromNib {
    UIView* selectedView = [[UIView alloc] initWithFrame:[[self contentView] bounds]];
    [selectedView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [selectedView setBackgroundColor:[HelloStyleKit questionAnswerSelectedBgColor]];
    [self setSelectedBackgroundView:selectedView];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [[self answerLabel] setBackgroundColor:[UIColor clearColor]];
    [[self answerLabel] setTextColor:[HelloStyleKit senseBlueColor]];
    [[self answerLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self answerLabel] setFont:[UIFont questionAnswerFont]];
    
    [[self separator] setBackgroundColor:[[HelloStyleKit senseBlueColor] colorWithAlphaComponent:0.5f]];
}

- (void)updateConstraints {
    [super updateConstraints];
    [[self separatorHeightConstraint] setConstant:0.5f];
}

- (UIColor*)colorForAnswerText:(BOOL)selected {
    return selected ? [HelloStyleKit questionAnswerSelectedTextColor] : [HelloStyleKit senseBlueColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [[self answerLabel] setTextColor:[self colorForAnswerText:selected]];
}

@end
