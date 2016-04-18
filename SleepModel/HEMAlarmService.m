//
//  HEMAlarmService.m
//  Sense
//
//  Created by Jimmy Lu on 12/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENAlarm.h>

#import "HEMAlarmService.h"
#import "HEMAlarmCache.h"

static NSUInteger const HEMAlarmServiceTooSoonMinuteLimit = 2;

@interface HEMAlarmService()

@property (nonatomic, strong) NSArray<SENSound*>* sounds;

@end

@implementation HEMAlarmService

- (void)loadAvailableAlarmSounds:(HEMAlarmSoundHandler)completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAlarms availableSoundsWithCompletion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [weakSelf setSounds:data];
        }
        completion (data, error);
    }];
}

- (void)refreshAlarms:(HEMAlarmsHandler)completion {
    [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        // FIXME: alarms are saved locally through the API call ...
        completion (data, error);
    }];
}

- (void)updateAlarms:(NSArray<SENAlarm*>*)alarms completion:(HEMAlarmUpdateHandler)completion {
    [SENAPIAlarms updateAlarms:alarms completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (error);
    }];
}

- (BOOL)isTimeTooSoon:(HEMAlarmCache*)cache {
    NSUInteger alarmHour = [cache hour];
    NSUInteger alarmMinute = [cache minute];
    
    NSDate* now = [NSDate date];
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSCalendarUnit units = (NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents* components = [calendar components:units fromDate:now];
    NSUInteger minuteCutOff = components.minute + HEMAlarmServiceTooSoonMinuteLimit;
    BOOL alarmIsInNextHour = (alarmHour == components.hour + 1 ||
                              (alarmHour == 0 && components.hour == 23));
    BOOL tooSoonInSameHour = (alarmHour == components.hour &&
                              alarmMinute >= components.minute &&
                              alarmMinute <= minuteCutOff);
    BOOL tooSoonInNextHour = (alarmIsInNextHour &&
                              components.minute > 59 - HEMAlarmServiceTooSoonMinuteLimit &&
                              alarmMinute < HEMAlarmServiceTooSoonMinuteLimit - (59 - components.minute));
    
    return tooSoonInSameHour || tooSoonInNextHour;
}

- (BOOL)willRingToday:(HEMAlarmCache*)cache {
    NSUInteger hour = [cache hour];
    NSUInteger minute = [cache minute];
    SENAlarmRepeatDays repeats = [cache repeatFlags];
    SENAlarmRepeatDays today = [self alarmRepeatDayForDate:[NSDate date]];
    
    if (repeats == 0 || (repeats & today) == today) {
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSCalendarUnit units = (NSCalendarUnitHour | NSCalendarUnitMinute);
        NSDateComponents *nowComponents = [calendar components:units fromDate:now];
        if (nowComponents.hour == hour) {
            return (minute >= nowComponents.minute);
        } else {
            return (hour > nowComponents.hour);
        }
    }
    
    return NO;
}

- (SENAlarmRepeatDays)alarmRepeatDayForDate:(NSDate*)date {
    NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    switch (components.weekday) {
        case 1: return SENAlarmRepeatSunday;
        case 2: return SENAlarmRepeatMonday;
        case 3: return SENAlarmRepeatTuesday;
        case 4: return SENAlarmRepeatWednesday;
        case 5: return SENAlarmRepeatThursday;
        case 6: return SENAlarmRepeatFriday;
        case 7: return SENAlarmRepeatSaturday;
        default:
            return 0;
    }
}

- (NSString*)localizedTextForRepeatFlags:(NSUInteger)alarmRepeatFlags {
    switch (alarmRepeatFlags) {
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
            if ((alarmRepeatFlags & SENAlarmRepeatSunday) == SENAlarmRepeatSunday)
                [days addObject:NSLocalizedString(@"alarm.repeat.days.sunday.short", nil)];
            if ((alarmRepeatFlags & SENAlarmRepeatMonday) == SENAlarmRepeatMonday)
                [days addObject:NSLocalizedString(@"alarm.repeat.days.monday.short", nil)];
            if ((alarmRepeatFlags & SENAlarmRepeatTuesday) == SENAlarmRepeatTuesday)
                [days addObject:NSLocalizedString(@"alarm.repeat.days.tuesday.short", nil)];
            if ((alarmRepeatFlags & SENAlarmRepeatWednesday) == SENAlarmRepeatWednesday)
                [days addObject:NSLocalizedString(@"alarm.repeat.days.wednesday.short", nil)];
            if ((alarmRepeatFlags & SENAlarmRepeatThursday) == SENAlarmRepeatThursday)
                [days addObject:NSLocalizedString(@"alarm.repeat.days.thursday.short", nil)];
            if ((alarmRepeatFlags & SENAlarmRepeatFriday) == SENAlarmRepeatFriday)
                [days addObject:NSLocalizedString(@"alarm.repeat.days.friday.short", nil)];
            if ((alarmRepeatFlags & SENAlarmRepeatSaturday) == SENAlarmRepeatSaturday)
                [days addObject:NSLocalizedString(@"alarm.repeat.days.saturday.short", nil)];
            return [days componentsJoinedByString:@" "];
        }
    }
}

- (void)copyCache:(HEMAlarmCache*)cache to:(SENAlarm*)alarm {
    [alarm setSmartAlarm:[cache isSmart]];
    [alarm setMinute:[cache minute]];
    [alarm setHour:[cache hour]];
    [alarm setRepeatFlags:[cache repeatFlags]];
    [alarm setSoundName:[cache soundName]];
    [alarm setSoundID:[cache soundID]];
    [alarm setOn:[cache isOn]];
    [alarm save];
}

@end
