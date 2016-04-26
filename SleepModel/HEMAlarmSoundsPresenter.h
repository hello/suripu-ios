//
//  HEMAlarmSoundsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 4/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSoundListPresenter.h"

@class HEMAudioService;
@class HEMAlarmService;

@interface HEMAlarmSoundsPresenter : HEMSoundListPresenter

- (instancetype)initWithNavTitle:(NSString *)title
                        subtitle:(NSString*)subtitle
                           items:(NSArray *)items
                selectedItemName:(NSString*)selectedItemName
                    audioService:(HEMAudioService*)audioService
                    alarmService:(HEMAlarmService*)alarmService;

@end
