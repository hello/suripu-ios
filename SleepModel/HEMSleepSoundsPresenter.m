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

@interface HEMSleepSoundsPresenter()

@property (nonatomic, weak) SENSleepSound* selectedSound;

@end

@implementation HEMSleepSoundsPresenter

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
             selectedItemName:(NSString*)selectedItemName
                 audioService:(HEMAudioService*)audioService {
    self = [super initWithTitle:title
                          items:items
               selectedItemName:selectedItemName
                   audioService:audioService];
    
    if (self) {
        [self configureSelectedSound];
    }
    
    return self;
}

- (void)configureSelectedSound {
    for (SENSleepSound* sound in [self items]) {
        if ([[sound localizedName] isEqualToString:[self selectedItemName]]) {
            [self setSelectedSound:sound];
            break;
        }
    }
}

#pragma mark - HEMSoundListPresenter Overrides

- (NSString*)selectedPreviewUrl {
    return [[self selectedSound] previewURL];
}

- (BOOL)item:(id)item matchesCurrentPreviewUrl:(NSString *)currentUrl {
    SENSleepSound* sound = item;
    return [currentUrl isEqualToString:[sound previewURL]];
}

#pragma mark -

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    
    SENSleepSound* sound = item;
    [[cell itemLabel] setText:[sound localizedName]];
    
    NSNumber* selectedSoundId = [[self selectedSound] identifier];
    BOOL selected = [selectedSoundId isEqualToNumber:[sound identifier]];
    [cell setSelected:selected];
}

- (void)cell:(HEMListItemCell *)cell isSelected:(BOOL)selected forItem:(id)item {
    [super cell:cell isSelected:selected forItem:item];

    SENSleepSound* sound = item;
    NSNumber* selectedSoundId = [[self selectedSound] identifier];
    if (selected && ![selectedSoundId isEqualToNumber:[sound identifier]]) {
        [self setSelectedSound:sound];
    }
}

@end
