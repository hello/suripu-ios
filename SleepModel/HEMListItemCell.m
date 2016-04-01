//
//  HEMListItemCell.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListItemCell.h"

@implementation HEMListItemCell

- (void)setSelected:(BOOL)selected {
    [[self selectionImageView] setHighlighted:selected];
}

@end
