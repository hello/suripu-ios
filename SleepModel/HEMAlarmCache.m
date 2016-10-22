//
//  HEMAlarmCache.m
//  Sense
//
//  Created by Delisa Mason on 10/7/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENExpansion.h>
#import "HEMAlarmCache.h"

@implementation HEMAlarmCache

- (void)cacheValuesFromAlarm:(SENAlarm*)alarm
{
    if (!alarm)
        return;
    self.hour = alarm.hour;
    self.minute = alarm.minute;
    self.soundName = alarm.soundName;
    self.smart = [alarm isSmartAlarm];
    self.repeatFlags = alarm.repeatFlags;
    self.soundID = alarm.soundID;
    self.on = [alarm isOn];
    self.expansions = [alarm expansions];
}

- (BOOL)isRepeated
{
    return self.repeatFlags != 0;
}

- (void)setAlarmExpansion:(SENAlarmExpansion*)alarmExpansion {
    NSMutableArray* mutableExpansions = [[self expansions] mutableCopy];
    if (!mutableExpansions) {
        mutableExpansions = [NSMutableArray arrayWithCapacity:2];
    }

    BOOL exists = NO;
    for (SENAlarmExpansion* savedExpansion in mutableExpansions) {
        if ([[savedExpansion expansionId] isEqualToNumber:[alarmExpansion expansionId]]) {
            [savedExpansion setEnable:[alarmExpansion isEnable]];
            [savedExpansion setTargetRange:[alarmExpansion targetRange]];
            exists = YES;
            break;
        }
    }
    
    if (!exists) {
        [mutableExpansions addObject:alarmExpansion];
    }
    
    [self setExpansions:mutableExpansions];
}

@end
