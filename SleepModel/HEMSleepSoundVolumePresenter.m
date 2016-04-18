//
//  HEMSleepSoundVolumePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSleepSoundVolumePresenter.h"
#import "HEMListItemCell.h"
#import "HEMSleepSoundVolume.h"
#import "HEMStyle.h"

@implementation HEMSleepSoundVolumePresenter

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    
    HEMSleepSoundVolume* volume = item;
    [[cell itemLabel] setText:[volume localizedName]];
    
    BOOL selected = [[volume localizedName] isEqualToString:[self selectedItemName]];
    [cell setSelected:selected];
}

@end
