//
//  AlarmListInterfaceController.m
//  Sense
//
//  Created by Delisa Mason on 1/17/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/Model.h>
#import <SenseKit/SENAPIAlarms.h>
#import "AlarmListInterfaceController.h"
#import "ModelCache.h"

@interface AlarmRowItem : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *scopeLabel;
@end

@implementation AlarmRowItem
@end

@interface AlarmListInterfaceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSArray *alarms;
@end

@implementation AlarmListInterfaceController

- (void)willActivate {
    [super willActivate];
    [self updateTable];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTable)
                                                 name:ModelCacheUpdatedNotification
                                               object:ModelCacheUpdatedObjectAlarms];
}

- (void)didDeactivate {
    [super didDeactivate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier
                            inTable:(WKInterfaceTable *)table
                           rowIndex:(NSInteger)rowIndex {
    return self.alarms[rowIndex];
}

- (void)updateTable {
    self.alarms = [ModelCache alarms];
    [self.table setNumberOfRows:self.alarms.count withRowType:@"watchAlarmList"];
    [self.alarms enumerateObjectsUsingBlock:^(SENAlarm *alarm, NSUInteger idx, BOOL *stop) {
      AlarmRowItem *row = [self.table rowControllerAtIndex:idx];
      [row.timeLabel setText:[[self localizedTimeForAlarm:alarm] lowercaseString]];
      [row.timeLabel setTextColor:[alarm isOn] ? [UIColor whiteColor] : [UIColor grayColor]];
      [row.scopeLabel setText:[self repeatTextForUnitFlags:alarm.repeatFlags]];
    }];
}

- (NSString *)localizedTimeForAlarm:(SENAlarm *)alarm {
    static NSString *const HEMAlarmTimeFormat = @"%ld:%@%@";
    static NSString *const HEMAlarmTimeMeridiemFormat = @"alarms.alarm.meridiem.%@";
    struct SENAlarmTime time = (struct SENAlarmTime){.hour = alarm.hour, .minute = alarm.minute };
    NSString *meridiem = nil;
    NSString *minuteText = time.minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)time.minute]
                                            : [NSString stringWithFormat:@"%ld", (long)time.minute];
    if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
        if (time.hour > 12) {
            time.hour = (long)(time.hour - 12);
            meridiem = @"pm";
        } else {
            if (time.hour == 0)
                time.hour = 12;
            meridiem = @"am";
        }
    } else {
        meridiem = @"";
    }
    NSString *meridiemKey = [NSString stringWithFormat:HEMAlarmTimeMeridiemFormat, meridiem];
    meridiem = NSLocalizedString(meridiemKey, nil);
    return [NSString stringWithFormat:HEMAlarmTimeFormat, time.hour, minuteText, meridiem];
}

- (NSString *)repeatTextForUnitFlags:(NSUInteger)alarmRepeatFlags {
    switch (alarmRepeatFlags) {
        case 0:
            return NSLocalizedString(@"alarm.repeat.days.none", nil);
        case (SENAlarmRepeatSaturday | SENAlarmRepeatSunday):
            return NSLocalizedString(@"alarm.repeat.days.weekends", nil);
        case (SENAlarmRepeatMonday | SENAlarmRepeatTuesday | SENAlarmRepeatWednesday | SENAlarmRepeatThursday
              | SENAlarmRepeatFriday):
            return NSLocalizedString(@"alarm.repeat.days.weekdays", nil);
        case (SENAlarmRepeatSunday | SENAlarmRepeatMonday | SENAlarmRepeatTuesday | SENAlarmRepeatWednesday
              | SENAlarmRepeatThursday | SENAlarmRepeatFriday | SENAlarmRepeatSaturday):
            return NSLocalizedString(@"alarm.repeat.days.all", nil);
        default: {
            NSMutableArray *days = [[NSMutableArray alloc] initWithCapacity:6];
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

@end
