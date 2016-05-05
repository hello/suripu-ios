
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import "HEMAlarmUtils.h"
#import "HEMAlarmCache.h"
#import "HEMAlertViewController.h"

NSUInteger const HEMAlarmTooSoonMinuteLimit = 2;

@implementation HEMAlarmUtils

+ (BOOL)timeIsTooSoonByHour:(NSUInteger)alarmHour minute:(NSUInteger)alarmMinute {
    NSDate* now = [NSDate date];
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSCalendarUnit units = (NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents* components = [calendar components:units fromDate:now];
    NSUInteger minuteCutOff = components.minute + HEMAlarmTooSoonMinuteLimit;
    BOOL alarmIsInNextHour = (alarmHour == components.hour + 1 ||
                              (alarmHour == 0 && components.hour == 23));
    BOOL tooSoonInSameHour = (alarmHour == components.hour &&
                              alarmMinute >= components.minute &&
                              alarmMinute <= minuteCutOff);
    BOOL tooSoonInNextHour = (alarmIsInNextHour &&
                              components.minute > 59 - HEMAlarmTooSoonMinuteLimit &&
                              alarmMinute < HEMAlarmTooSoonMinuteLimit - (59 - components.minute));
    
    return tooSoonInSameHour || tooSoonInNextHour;
}

+ (NSString*)repeatTextForUnitFlags:(NSUInteger)alarmRepeatFlags
{
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

+ (BOOL)willRingTodayWithHour:(NSUInteger)hour
                       minute:(NSUInteger)minute
                   repeatDays:(SENAlarmRepeatDays)repeatDays {
    SENAlarmRepeatDays today = [self alarmRepeatDayForDate:[NSDate date]];
    if (repeatDays == 0 || (repeatDays & today) == today) {
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

+ (SENAlarmRepeatDays)alarmRepeatDayForDate:(NSDate*)date
{
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

+ (void)refreshAlarmsFromPresentingController:(UIViewController*)controller completion:(void (^)(NSError*))completion {
    [SENAPIAlarms alarmsWithCompletion:^(NSArray* alarms, NSError* error) {
        if (completion)
            completion(error);
    }];
}

+ (void)updateAlarmsFromPresentingController:(UIViewController*)controller completion:(void (^)(NSError*))completion
{
    NSArray* rightButtons = controller.navigationItem.rightBarButtonItems;
    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem* loadItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    controller.navigationItem.rightBarButtonItems = @[loadItem];
    [indicatorView startAnimating];
    [SENAPIAlarms updateAlarms:[SENAlarm savedAlarms] completion:^(id data, NSError* error) {
        [indicatorView stopAnimating];
        controller.navigationItem.rightBarButtonItems = rightButtons;
        if (error) {
            [self showError:error
                  withTitle:NSLocalizedString(@"alarm.save-error.title", nil)
               onController:controller];
        }
        if (controller && completion)
            completion(error);
    }];
}

+ (void)showError:(NSError*)error withTitle:(NSString*)title onController:(UIViewController*)controller
{
    [HEMAlertViewController showInfoDialogWithTitle:title
                                            message:error.localizedDescription
                                         controller:controller];
}

@end
