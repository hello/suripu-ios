//
//  HEMMultpleResponseCell.m
//  Sense
//
//  Created by Jimmy Lu on 12/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMMultipleResponseCell.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

@interface HEMMultipleResponseCell()

@property (weak, nonatomic) IBOutlet UIImageView *checkbox;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;

@end

@implementation HEMMultipleResponseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView* selectedView = [[UIView alloc] initWithFrame:[[self contentView] bounds]];
    [selectedView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [selectedView setBackgroundColor:[UIColor whiteColor]];
    [self setSelectedBackgroundView:selectedView];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [[self checkbox] setHidden:selected];
    [[self selectedView] setHidden:!selected];
    // label handled by super class
}

@end
