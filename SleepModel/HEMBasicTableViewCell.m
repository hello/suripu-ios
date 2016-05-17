//
//  HEMBasicTableViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBasicTableViewCell.h"
#import "HEMStyle.h"

static CGFloat const HEMBasicTableViewCellSeparatorHeight = 0.5f;

@interface HEMBasicTableViewCell()

@property (nonatomic, strong) UIView* customSeparator;

@end

@implementation HEMBasicTableViewCell

- (void)showSeparator:(BOOL)show {
    if (![self customSeparator] && show) {
        CGFloat cellHeight = CGRectGetHeight([self bounds]);
        CGFloat y = cellHeight - HEMBasicTableViewCellSeparatorHeight;
        CGRect separatorFrame = CGRectZero;
        separatorFrame.size.height = HEMBasicTableViewCellSeparatorHeight;
        separatorFrame.origin.y = y;
        UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
        [separator setBackgroundColor:[UIColor separatorColor]];
        [self setCustomSeparator:separator];
        [[self contentView] addSubview:separator];
    }
    [[self customSeparator] setHidden:!show];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (![[self customSeparator] isHidden]) {
        CGFloat cellHeight = CGRectGetHeight([self bounds]);
        CGFloat cellWidth = CGRectGetWidth([self bounds]);
        CGFloat labelMinX = CGRectGetMinX([[self textLabel] frame]);
        CGFloat y = cellHeight - HEMBasicTableViewCellSeparatorHeight;
        CGRect separatorFrame = [[self customSeparator] frame];
        separatorFrame.size.height = HEMBasicTableViewCellSeparatorHeight;
        separatorFrame.size.width = cellWidth - labelMinX;
        separatorFrame.origin.y = y;
        separatorFrame.origin.x = labelMinX;
        [[self customSeparator] setFrame:separatorFrame];
    }
    
    
}

@end
