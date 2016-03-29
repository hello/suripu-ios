//
//  HEMSleepSoundsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSleepSounds.h>

#import "HEMSleepSoundsPresenter.h"
#import "HEMListItemCell.h"
#import "HEMStyle.h"

@implementation HEMSleepSoundsPresenter

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    
    SENSleepSound* sound = item;
    [[cell itemLabel] setText:[sound localizedName]];
    
    BOOL selected = [[sound localizedName] isEqualToString:[self selectedItemName]];
    [cell setSelected:selected];
}

@end
