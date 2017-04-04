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
    
@property (nonatomic, strong) UIView* disableOverlay;
    
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
    [self setUserInteractionEnabled:enable];
    
    if (!enable) {
        if (![self disableOverlay]) {
            [self setDisableOverlay:[[UIView alloc] initWithFrame:[self bounds]]];
        }
        [[self disableOverlay] applyDisabledOverlayStyle];
        [self addSubview:[self disableOverlay]];
    } else {
        [[self disableOverlay] removeFromSuperview];
    }
}

@end
