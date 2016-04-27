//
//  HEMSleepSoundDurationsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSleepSoundDurations.h>

#import "HEMSleepSoundDurationsPresenter.h"
#import "HEMListItemCell.h"
#import "HEMStyle.h"

@implementation HEMSleepSoundDurationsPresenter

- (NSInteger)indexOfItemWithName:(NSString*)name {
    NSInteger index = -1;
    NSInteger durationIndex = 0;
    for (SENSleepSoundDuration* duration in [self items]) {
        if ([[duration localizedName] isEqualToString:name]) {
            index = durationIndex;
            break;
        }
        durationIndex++;
    }
    return index;
}

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    
    SENSleepSoundDuration* duration = item;
    
    [[cell itemLabel] setText:[duration localizedName]];
    
    NSString* selectedName = [[self selectedItemNames] firstObject];
    BOOL selected = [[duration localizedName] isEqualToString:selectedName];
    [cell setSelected:selected];
}

@end
