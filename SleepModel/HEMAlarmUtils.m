
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import "HEMAlarmUtils.h"

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

+ (void)updateAlarmFromPresentingController:(UIViewController*)controller completion:(void (^)(BOOL))completion
{
    UIBarButtonItem* saveButton = controller.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem* loadItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    controller.navigationItem.rightBarButtonItem = loadItem;
    [indicatorView startAnimating];
    [SENAPIAlarms updateAlarms:[SENAlarm savedAlarms] completion:^(id data, NSError* error) {
        [indicatorView stopAnimating];
        controller.navigationItem.rightBarButtonItem = saveButton;
        if (error) {
            if (NSClassFromString(@"UIAlertController")) {
                UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alarm.error.title", nil)
                                                                                         message:error.localizedDescription
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"actions.ok", nil) style:UIAlertActionStyleDefault handler:NULL];
                [alertController addAction:action];
                [controller presentViewController:alertController animated:YES completion:NULL];
            } else {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alarm.error.title", nil)
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil];
                [alertView show];
            }
        }
        if (controller && completion)
            completion(!error);
    }];
}

@end
