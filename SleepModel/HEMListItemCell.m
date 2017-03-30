//
//  HEMListItemCell.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMListItemCell.h"

@interface HEMListItemCell()
    
@property (nonatomic, weak) UIView* disableOverlay;
    
@end

@implementation HEMListItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[self selectionImageView] setUserInteractionEnabled:NO];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected {
    [[self selectionImageView] setHighlighted:selected];
}
    
- (void)enable:(BOOL)enable {
    if (!enable && [self disableOverlay] == nil) {
        UIView* view = [[UIView alloc] initWithFrame:[self bounds]];
        [view applyDisabledOverlayStyle];
        [[self contentView] addSubview:view];
    } else {
        [[self disableOverlay] removeFromSuperview];
    }
}

@end
