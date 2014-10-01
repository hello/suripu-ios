
#import <SenseKit/SENAlarm.h>
#import "HEMAlarmTextUtils.h"

@implementation HEMAlarmTextUtils

+ (NSString*)repeatTextForAlarm:(SENAlarm*)alarm
{
    switch (alarm.repeatFlags) {
    case 0:
        return NSLocalizedString(@"alarm.repeat.days.none", nil);
    case (SENAlarmRepeatSaturday | SENAlarmRepeatSunday):
        return NSLocalizedString(@"alarm.repeat.days.weekends", nil);
    case (SENAlarmRepeatMonday | SENAlarmRepeatTuesday | SENAlarmRepeatWednesday | SENAlarmRepeatThursday | SENAlarmRepeatFriday):
        return NSLocalizedString(@"alarm.repeat.days.weekdays", nil);
    case (SENAlarmRepeatSunday | SENAlarmRepeatMonday | SENAlarmRepeatTuesday | SENAlarmRepeatWednesday | SENAlarmRepeatThursday | SENAlarmRepeatFriday | SENAlarmRepeatSaturday):
        return NSLocalizedString(@"alarm.repeat.days.all", nil);
    default: {
        NSMutableArray* days = [[NSMutableArray alloc] initWithCapacity:6];
        if ((alarm.repeatFlags & SENAlarmRepeatSunday) == SENAlarmRepeatSunday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.sunday.short", nil)];
        if ((alarm.repeatFlags & SENAlarmRepeatMonday) == SENAlarmRepeatMonday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.monday.short", nil)];
        if ((alarm.repeatFlags & SENAlarmRepeatTuesday) == SENAlarmRepeatTuesday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.tuesday.short", nil)];
        if ((alarm.repeatFlags & SENAlarmRepeatWednesday) == SENAlarmRepeatWednesday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.wednesday.short", nil)];
        if ((alarm.repeatFlags & SENAlarmRepeatThursday) == SENAlarmRepeatThursday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.thursday.short", nil)];
        if ((alarm.repeatFlags & SENAlarmRepeatFriday) == SENAlarmRepeatFriday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.friday.short", nil)];
        if ((alarm.repeatFlags & SENAlarmRepeatSaturday) == SENAlarmRepeatSaturday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.saturday.short", nil)];
        return [days componentsJoinedByString:@" "];
    }
    }
}

@end