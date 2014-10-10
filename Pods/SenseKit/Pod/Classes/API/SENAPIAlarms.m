
#import "SENAPIAlarms.h"
#import "SENAlarm.h"

@implementation SENAPIAlarms

static NSString* const SENAPIAlarmsEndpoint = @"alarms";
static NSString* const SENAPIAlarmsUpdateEndpointFormat = @"alarms/%.0f";

+ (void)alarmsWithCompletion:(SENAPIDataBlock)completion
{
    if (!completion)
        return;
    [SENAPIClient GET:SENAPIAlarmsEndpoint
           parameters:nil
           completion:^(NSArray* data, NSError* error) {
               if (error) {
                   completion(nil, error);
                   return;
               }
               NSMutableArray* alarms = [[NSMutableArray alloc] initWithCapacity:data.count];
               for (NSDictionary* alarmData in data) {
                   SENAlarm* alarm = [[SENAlarm alloc] initWithDictionary:alarmData];
                   if (alarm)
                       [alarms addObject:alarm];
               }
               completion(alarms, nil);
           }];
}

+ (void)updateAlarms:(NSArray*)alarms completion:(SENAPIDataBlock)completion
{
    CGFloat clientTimeUTC = [[NSDate date] timeIntervalSince1970] * 1000;
    NSArray* alarmData = [self parameterArrayForAlarms:alarms];
    [SENAPIClient POST:[NSString stringWithFormat:SENAPIAlarmsUpdateEndpointFormat, clientTimeUTC]
            parameters:alarmData
            completion:completion];
}

+ (NSArray*)parameterArrayForAlarms:(NSArray*)alarms
{
    NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:alarms.count];
    for (SENAlarm* alarm in alarms) {
        if ([alarm isKindOfClass:[SENAlarm class]]) {
            NSDictionary* alarmRepresentation = [self dictionaryForAlarm:alarm];
            if (alarmRepresentation) {
                [data addObject:alarmRepresentation];
            }
        }
    }
    return data;
}

+ (NSDictionary*)dictionaryForAlarm:(SENAlarm*)alarm
{
    BOOL repeated = alarm.repeatFlags != 0;
    NSMutableDictionary* alarmRepresentation = [NSMutableDictionary new];
    alarmRepresentation[@"editable"] = @([alarm isEditable]);
    alarmRepresentation[@"enabled"] = @([alarm isOn]);
    if (alarm.soundName.length > 0)
        alarmRepresentation[@"sound"] = @{ @"name" : alarm.soundName };
    else
        alarmRepresentation[@"sound"] = @{};
    alarmRepresentation[@"hour"] = @(alarm.hour);
    alarmRepresentation[@"minute"] = @(alarm.minute);
    alarmRepresentation[@"repeated"] = @(repeated);
    alarmRepresentation[@"day_of_week"] = [self repeatDaysForAlarm:alarm];
    return alarmRepresentation;
}

+ (NSArray*)repeatDaysForAlarm:(SENAlarm*)alarm
{
    NSMutableArray* repeatDays = [[NSMutableArray alloc] initWithCapacity:7];
    if ((alarm.repeatFlags & SENAlarmRepeatMonday) == SENAlarmRepeatMonday)
        [repeatDays addObject:@(SENAPIAlarmsRepeatDayMonday)];
    if ((alarm.repeatFlags & SENAlarmRepeatTuesday) == SENAlarmRepeatTuesday)
        [repeatDays addObject:@(SENAPIAlarmsRepeatDayTuesday)];
    if ((alarm.repeatFlags & SENAlarmRepeatWednesday) == SENAlarmRepeatWednesday)
        [repeatDays addObject:@(SENAPIAlarmsRepeatDayWednesday)];
    if ((alarm.repeatFlags & SENAlarmRepeatThursday) == SENAlarmRepeatThursday)
        [repeatDays addObject:@(SENAPIAlarmsRepeatDayThursday)];
    if ((alarm.repeatFlags & SENAlarmRepeatFriday) == SENAlarmRepeatFriday)
        [repeatDays addObject:@(SENAPIAlarmsRepeatDayFriday)];
    if ((alarm.repeatFlags & SENAlarmRepeatSaturday) == SENAlarmRepeatSaturday)
        [repeatDays addObject:@(SENAPIAlarmsRepeatDaySaturday)];
    if ((alarm.repeatFlags & SENAlarmRepeatSunday) == SENAlarmRepeatSunday)
        [repeatDays addObject:@(SENAPIAlarmsRepeatDaySunday)];

    return repeatDays;
}

@end
