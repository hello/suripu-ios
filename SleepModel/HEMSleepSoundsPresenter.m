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
@property (nonatomic, copy) NSString* selectedSoundName;

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
    NSString* selectedName = [[self selectedItemNames] firstObject];
    if (selectedName) {
        for (SENSleepSound* sound in [self items]) {
            if ([[sound localizedName] isEqualToString:selectedName]) {
                [self setSelectedSound:sound];
                break;
            }
        }
    }
}

#pragma mark - HEMSoundListPresenter Overrides

- (NSInteger)indexOfItemWithName:(NSString*)name {
    NSInteger index = -1;
    NSInteger itemIndex = 0;
    for (SENSleepSound* sound in [self items]) {
        if ([[sound localizedName] isEqualToString:name]) {
            index = itemIndex;
            break;
        }
        itemIndex++;
    }
    return index;
}

- (NSString*)selectedPreviewUrl {
    return [[self selectedSound] previewURL];
}

- (BOOL)item:(id)item matchesCurrentPreviewUrl:(NSString *)currentUrl {
    SENSleepSound* sound = item;
    return [currentUrl isEqualToString:[sound previewURL]];
}

- (void)updateCell:(UITableViewCell *)cell withItem:(id)item selected:(BOOL)selected {
    [super updateCell:cell withItem:item selected:selected];
    if (selected) {
        [self setSelectedSound:item];
    }
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

@end
