//
//  HEMAlarmService.m
//  Sense
//
//  Created by Jimmy Lu on 12/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENPreference.h>
#import <SenseKit/SENAlarmCollection.h>
#import <SenseKit/SENExpansion.h>

#import "HEMAlarmService.h"
#import "HEMAlarmCache.h"

static NSUInteger const HEMAlarmServiceTooSoonMinuteLimit = 2;
static NSUInteger const HEMAlarmServiceMaxAlarmLimit = 30; // matches server

@interface HEMAlarmService()

@property (nonatomic, strong) NSArray<SENSound*>* sounds;
@property (nonatomic, strong) NSArray<SENAlarm*>* alarms;

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

- (NSArray *)sortAlarms:(NSArray*)alarms {
    return [alarms sortedArrayUsingComparator:^NSComparisonResult(SENAlarm *obj1, SENAlarm *obj2) {
        NSNumber *alarmValue1 = @(obj1.hour * 60 + obj1.minute);
        NSNumber *alarmValue2 = @(obj2.hour * 60 + obj2.minute);
        NSComparisonResult result = [alarmValue1 compare:alarmValue2];
        if (result == NSOrderedSame)
            result = [@(obj1.repeatFlags) compare:@(obj2.repeatFlags)];
        return result;
    }];
}

- (void)handleAlarmResponse:(id)data error:(NSError*)error {
    if (error) {
        [SENAnalytics trackError:error];
    } else if ([data isKindOfClass:[SENAlarmCollection class]]) {
        // build a single list from the collection of alarms
        SENAlarmCollection* collection = data;
        NSMutableArray* allAlarms = [NSMutableArray arrayWithCapacity:HEMAlarmServiceMaxAlarmLimit];
        if ([collection expansionAlarms]) {
            [allAlarms addObjectsFromArray:[collection expansionAlarms]];
        }
        if ([collection voiceAlarms]) {
            [allAlarms addObjectsFromArray:[collection voiceAlarms]];
        }
        if ([collection classicAlarms]) {
            [allAlarms addObjectsFromArray:[collection classicAlarms]];
        }
        [self setAlarms:[self sortAlarms:allAlarms]];
    } else {
        [self setAlarms:@[]];
    }
}

- (void)refreshAlarms:(HEMAlarmsHandler)completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf handleAlarmResponse:data error:error];
        if (completion) {
            completion ([strongSelf alarms], error);
        }
    }];
}

- (void)updateAlarms:(NSArray<SENAlarm*>*)alarms completion:(HEMAlarmUpdateHandler)completion {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SENAlarmCollection* collection = [[SENAlarmCollection alloc] initWithAlarms:alarms];
        [SENAPIAlarms updateAlarms:collection completion:^(id data, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf handleAlarmResponse:data error:error];
            if (completion) {
                completion (error);
            }
        }];
    });
}

- (BOOL)isTimeTooSoon:(HEMAlarmCache*)cache {
    NSUInteger alarmHour = [cache hour];
    NSUInteger alarmMinute = [cache minute];
    return [self isTimeTooSoonWithHour:alarmHour andMinute:alarmMinute];
}

- (BOOL)isAlarmTimeTooSoon:(SENAlarm *)alarm {
    NSUInteger alarmHour = [alarm hour];
    NSUInteger alarmMinute = [alarm minute];
    return [self isTimeTooSoonWithHour:alarmHour andMinute:alarmMinute];
}

- (BOOL)isTimeTooSoonWithHour:(NSUInteger)alarmHour andMinute:(NSUInteger)alarmMinute {
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
    return [self willRingTodayWithHour:hour minute:minute repeat:repeats];
}

- (BOOL)willAlarmRingToday:(SENAlarm*)alarm {
    NSUInteger hour = [alarm hour];
    NSUInteger minute = [alarm minute];
    SENAlarmRepeatDays repeats = [alarm repeatFlags];
    return [self willRingTodayWithHour:hour minute:minute repeat:repeats];
}

- (BOOL)willRingTodayWithHour:(NSUInteger)hour minute:(NSUInteger)minute repeat:(SENAlarmRepeatDays)repeat {
    SENAlarmRepeatDays today = [self alarmRepeatDayForDate:[NSDate date]];
    
    if (repeat == 0 || (repeat & today) == today) {
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

- (BOOL)canAddRepeatDay:(SENAlarmRepeatDays)day
                     to:(HEMAlarmCache*)alarmCache
              excluding:(SENAlarm*)excludedAlarm {
    
    if (![alarmCache isSmart]) {
        return YES;
    }
    
    SENAlarmRepeatDays daysInUse = 0;

    for (SENAlarm* alarm in [self alarms]) {
        if ([alarm isEqual:excludedAlarm]
            || ![alarm isSmartAlarm]
            || ![alarm isOn]) {
            continue;
        }
        
        if ([alarm isRepeated]) {
            daysInUse |= [alarm repeatFlags];
        } else {
            daysInUse |= [self dayForNonRepeatingAlarmWithHour:[alarm hour]
                                                        minute:[alarm minute]];
        }
    }
    
    return (daysInUse & day) == 0; // not in use
}

- (SENAlarmRepeatDays)dayForNonRepeatingAlarmWithHour:(NSUInteger)hour minute:(NSUInteger)minute {
    NSDate* fireDate = [SENAlarm nextRingDateWithHour:hour minute:minute];
    return [self alarmRepeatDayForDate:fireDate];
}

- (void)copyCache:(HEMAlarmCache*)cache to:(SENAlarm*)alarm {
    [alarm setSmartAlarm:[cache isSmart]];
    [alarm setMinute:[cache minute]];
    [alarm setHour:[cache hour]];
    [alarm setRepeatFlags:[cache repeatFlags]];
    [alarm setSoundName:[cache soundName]];
    [alarm setSoundID:[cache soundID]];
    [alarm setOn:[cache isOn]];
    [alarm setExpansions:[cache expansions]];
}

- (BOOL)canCreateMoreAlarms {
    return [[self alarms] count] < HEMAlarmServiceMaxAlarmLimit;
}

- (BOOL)useMilitaryTimeFormat {
    return [SENPreference timeFormat] == SENTimeFormat24Hour;
}

- (BOOL)hasLoadedAlarms {
    return [self alarms] != nil;
}

- (BOOL)isExpansionEnabledFor:(SENExpansion*)expansion inAlarmCache:(HEMAlarmCache*)alarm {
    for (SENAlarmExpansion* alarmExpansion in [alarm expansions]) {
        if ([[expansion identifier] isEqualToNumber:[alarmExpansion expansionId]]) {
            return [alarmExpansion isEnable];
        }
    }
    return NO;
}

- (BOOL)hasLightsEnabledForAlarm:(SENAlarm*)alarm {
    SENAlarmExpansion* expansion = [[alarm expansions] lastObject];
    return [expansion isEnable];
}

@end
