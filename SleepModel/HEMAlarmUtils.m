
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import "HEMAlarmUtils.h"
#import "HEMAlertController.h"

@implementation HEMAlarmUtils

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

+ (BOOL)dayInUse:(NSUInteger)day excludingAlarm:(SENAlarm*)excludedAlarm
{
    NSUInteger daysInUse = 0;
    for (SENAlarm* alarm in [SENAlarm savedAlarms]) {
        if ([alarm isEqual:excludedAlarm] || ![alarm isSmartAlarm])
            continue;
        if (alarm.repeatFlags != 0) {
            daysInUse |= alarm.repeatFlags;
        } else {
            daysInUse |= [self fireDayForNonRepeatingAlarm:alarm];
        }
    }
    return (daysInUse & day) == day;
}

+ (SENAlarmRepeatDays)fireDayForNonRepeatingAlarm:(SENAlarm*)alarm
{
    NSDate* fireDate = [alarm nextRingDate];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitWeekday fromDate:fireDate];
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

+ (void)refreshAlarmsFromPresentingController:(UIViewController*)controller completion:(void (^)(NSError*))completion
{
    UIBarButtonItem* rightButton = controller.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem* loadItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    controller.navigationItem.rightBarButtonItem = loadItem;
    [indicatorView startAnimating];
    __weak typeof(controller) weakController = controller;
    [SENAPIAlarms alarmsWithCompletion:^(NSArray* alarms, NSError* error) {
        __strong typeof(weakController) strongController = weakController;
        if (error) {
            [self showError:error
                  withTitle:NSLocalizedString(@"alarm.load-error.title", nil)
               onController:strongController];
        } else {
            [SENAlarm clearSavedAlarms];
            for (SENAlarm* alarm in alarms) {
                [alarm save];
            }
        }
        [indicatorView stopAnimating];
        strongController.navigationItem.rightBarButtonItem = rightButton;
        if (completion)
            completion(error);
    }];
}

+ (void)updateAlarmsFromPresentingController:(UIViewController*)controller completion:(void (^)(BOOL))completion
{
    UIBarButtonItem* rightButton = controller.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem* loadItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    controller.navigationItem.rightBarButtonItem = loadItem;
    [indicatorView startAnimating];
    [SENAPIAlarms updateAlarms:[SENAlarm savedAlarms] completion:^(id data, NSError* error) {
        [indicatorView stopAnimating];
        controller.navigationItem.rightBarButtonItem = rightButton;
        if (error) {
            [self showError:error
                  withTitle:NSLocalizedString(@"alarm.save-error.title", nil)
               onController:controller];
        }
        if (controller && completion)
            completion(!error);
    }];
}

+ (void)showError:(NSError*)error withTitle:(NSString*)title onController:(UIViewController*)controller
{
    [HEMAlertController presentInfoAlertWithTitle:title
                                          message:error.localizedDescription
                             presentingController:controller];
}

@end
