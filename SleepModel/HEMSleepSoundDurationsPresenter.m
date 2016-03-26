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

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    
    SENSleepSoundDuration* duration = item;
    BOOL selected = [[duration localizedName] isEqualToString:[self selectedItemName]];
    [[cell itemLabel] setText:[duration localizedName]];
    [[cell selectionImageView] setHidden:!selected];
}

@end
