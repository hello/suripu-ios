
#import <AFNetworking/AFURLResponseSerialization.h>
#import "SENAPIAlarms.h"
#import "Model.h"

@implementation SENAPIAlarms

static NSString* const SENAPIAlarmsEndpoint = @"v1/alarms";
static NSString* const SENAPIAlarmSoundsEndpoint = @"v1/alarms/sounds";
static NSString* const SENAPIAlarmsUpdateEndpointFormat = @"v1/alarms/%.0f";

static SENAPIDataBlock SENAPIAlarmDataBlock(SENAPIDataBlock completion) {
    return ^(NSArray* data, NSError* error) {
        NSArray* alarms = nil;
        if (data && [data isKindOfClass:[NSArray class]]) {
            alarms = [SENAlarm updateSavedAlarmsWithData:data];
        }

        if (completion)
            completion(alarms, error);
    };
}

+ (void)alarmsWithCompletion:(SENAPIDataBlock)completion
{
    if (!completion)
        return;
    [SENAPIClient GET:SENAPIAlarmsEndpoint
           parameters:nil
           completion:SENAPIAlarmDataBlock(completion)];
}

+ (void)updateAlarms:(NSArray*)alarms completion:(SENAPIDataBlock)completion
{
    NSTimeInterval clientTimeUTC = [SENDateMillisecondsSince1970([NSDate date]) doubleValue];
    NSArray* alarmData = [self parameterArrayForAlarms:alarms];
    [SENAPIClient POST:[NSString stringWithFormat:SENAPIAlarmsUpdateEndpointFormat, clientTimeUTC]
            parameters:alarmData
            completion:SENAPIAlarmDataBlock(completion)];
}

+ (void)availableSoundsWithCompletion:(SENAPIDataBlock)completion
{
    if (!completion)
        return;

    [SENAPIClient GET:SENAPIAlarmSoundsEndpoint parameters:nil completion:^(NSArray* data, NSError *error) {
        if (error || ![data isKindOfClass:[NSArray class]]) {
            completion(nil, error);
            return;
        }
        NSMutableArray* sounds = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary* soundData in data) {
            SENSound* sound = [[SENSound alloc] initWithDictionary:soundData];
            if (sound)
                [sounds addObject:sound];
        }
        completion(sounds, nil);
    }];
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
    NSMutableDictionary* properties = [NSMutableDictionary new];
    
    properties[@"editable"] = @([alarm isEditable]);
    properties[@"enabled"] = @([alarm isOn]);
    properties[@"sound"] = @{
        @"name" : alarm.soundName ?: @"",
        @"id" : alarm.soundID ?: @""
    };
    if (alarm.identifier.length > 0)
        properties[@"id"] = alarm.identifier;

    properties[@"hour"] = @(alarm.hour);
    properties[@"minute"] = @(alarm.minute);
    properties[@"repeated"] = @(repeated);
    properties[@"smart"] = @([alarm isSmartAlarm]);
    properties[@"day_of_week"] = [self repeatDaysForAlarm:alarm];

    if (!repeated) {
        NSDateComponents* alarmDateComponents = [self dateComponentsForAlarm:alarm];
        properties[@"day_of_month"] = @(alarmDateComponents.day);
        properties[@"month"] = @(alarmDateComponents.month);
        properties[@"year"] = @(alarmDateComponents.year);
    }

    return properties;
}

+ (NSDateComponents*)dateComponentsForAlarm:(SENAlarm*)alarm
{
    NSCalendarUnit flags = (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay);
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [calendar components:flags fromDate:[alarm nextRingDate]];
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
