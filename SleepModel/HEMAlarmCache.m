//
//  HEMAlarmCache.m
//  Sense
//
//  Created by Delisa Mason on 10/7/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAlarm.h>
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
}

- (BOOL)isRepeated
{
    return self.repeatFlags != 0;
}

@end
