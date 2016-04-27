//
//  HEMSleepSoundsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSoundListPresenter.h"

@class HEMAudioService;

@interface HEMSleepSoundsPresenter : HEMSoundListPresenter

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
            selectedItemNames:(NSArray*)selectedItemNames NS_UNAVAILABLE;

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
             selectedItemName:(NSString*)selectedItemName
                 audioService:(HEMAudioService*)audioService NS_DESIGNATED_INITIALIZER;

@end
