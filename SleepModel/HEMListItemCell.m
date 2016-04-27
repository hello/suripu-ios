//
//  HEMListItemCell.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListItemCell.h"

@implementation HEMListItemCell

- (void)awakeFromNib {
    [[self selectionImageView] setUserInteractionEnabled:NO];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected {
    [[self selectionImageView] setHighlighted:selected];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    DDLogVerbose(@"laying out");
}

@end
