//
//  HEMTextCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import "HEMInsightTextCollectionViewCell.h"
#import "HelloStyleKit.h"

@interface HEMInsightTextCollectionViewCell()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* separatorHeightConstraint;

@end

@implementation HEMInsightTextCollectionViewCell

- (void)awakeFromNib {
    [self setBackgroundColor:[UIColor clearColor]];
    [[self contentView] setBackgroundColor:[UIColor clearColor]];
    
    [[self textLabel] setNumberOfLines:0];
    [[self textLabel] setBackgroundColor:[UIColor clearColor]];
    
    [[self separator] setBackgroundColor:[HelloStyleKit separatorColor]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self textLabel] setText:nil];
    [[self separator] setHidden:YES];
}

@end
