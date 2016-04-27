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

- (NSInteger)indexOfItemWithName:(NSString*)name {
    NSInteger index = -1;
    NSInteger itemIndex = 0;
    for (HEMSleepSoundVolume* volume in [self items]) {
        if ([[volume localizedName] isEqualToString:name]) {
            index = itemIndex;
            break;
        }
        itemIndex++;
    }
    return index;
}

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    
    HEMSleepSoundVolume* volume = item;
    [[cell itemLabel] setText:[volume localizedName]];
    
    NSString* selectedName = [[self selectedItemNames] firstObject];
    if (selectedName) {
        BOOL selected = [[volume localizedName] isEqualToString:selectedName];
        [cell setSelected:selected];
    }
}

@end
