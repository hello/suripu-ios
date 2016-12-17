//
//  HEMListItemCell.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListItemCell.h"
#import "HEMStyle.h"

static CGFloat const HEMListItemTouchAnimDuration = 0.2f;

@implementation HEMListItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[self selectionImageView] setUserInteractionEnabled:NO];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UIView* touchView = [[UIView alloc] initWithFrame:[self bounds]];
    [touchView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [touchView setBackgroundColor:[UIColor touchIndicatorColor]];
    [touchView setHidden:YES];
    [touchView setAlpha:0.0f];
    [self setBackgroundView:touchView];
}

- (void)setSelected:(BOOL)selected {
    [[self selectionImageView] setHighlighted:selected];
    [[self backgroundView] setHidden:NO];
}

- (void)flashTouchIndicator {
    [UIView animateWithDuration:HEMListItemTouchAnimDuration animations:^{
        [[self backgroundView] setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:HEMListItemTouchAnimDuration animations:^{
            [[self backgroundView] setAlpha:0.0f];
        }];
    }];
}

@end
