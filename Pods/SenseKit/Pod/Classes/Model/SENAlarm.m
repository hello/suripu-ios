
#import "SENAlarm.h"
#import "SENAPIAlarms.h"
#import "SENSettings.h"
#import "SENKeyedArchiver.h"

@interface SENAlarm ()
@property (nonatomic, strong) NSString* identifier;
@end

@implementation SENAlarm

static NSString* const SENAlarmSoundNameKey = @"sound";
static NSString* const SENAlarmOnKey = @"on";
static NSString* const SENAlarmSmartKey = @"smart";
static NSString* const SENAlarmEditableKey = @"editable";
static NSString* const SENAlarmHourKey = @"hour";
static NSString* const SENAlarmMinuteKey = @"minute";
static NSString* const SENAlarmRepeatKey = @"day_of_week";
static NSString* const SENAlarmIdentifierKey = @"identifier";

static NSString* const SENAlarmDefaultSoundName = @"None";
static NSUInteger const SENAlarmDefaultHour = 7;
static NSUInteger const SENAlarmDefaultMinute = 30;
static BOOL const SENAlarmDefaultOnState = YES;
static BOOL const SENAlarmDefaultEditableState = YES;
static BOOL const SENAlarmDefaultSmartAlarmState = YES;

+ (NSArray*)savedAlarms
{
    return [SENKeyedArchiver allObjectsInCollection:NSStringFromClass([self class])];
}

+ (SENAlarm*)createDefaultAlarm
{
    return [[SENAlarm alloc] initWithDictionary:@{
        SENAlarmSoundNameKey : SENAlarmDefaultSoundName,
        SENAlarmHourKey : @(SENAlarmDefaultHour),
        SENAlarmMinuteKey : @(SENAlarmDefaultMinute),
        SENAlarmOnKey : @(SENAlarmDefaultOnState),
        SENAlarmEditableKey : @(SENAlarmDefaultEditableState),
        SENAlarmSmartKey : @(SENAlarmDefaultSmartAlarmState),
        SENAlarmRepeatKey : @[]
    }];
}

+ (void)clearSavedAlarms
{
    [SENKeyedArchiver removeAllObjectsInCollection:NSStringFromClass([self class])];
}

+ (NSString*)localizedValueForTime:(struct SENAlarmTime)time
{
    long adjustedHour = time.hour;
    NSString* formatString;
    NSString* minuteText = time.minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)time.minute] : [NSString stringWithFormat:@"%ld", (long)time.minute];
    if ([SENSettings timeFormat] == SENTimeFormat12Hour) {
        formatString = time.hour > 11 ? @"%ld:%@pm" : @"%ld:%@am";
        if (time.hour > 12) {
            adjustedHour = (long)(time.hour - 12);
        } else if (time.hour == 0) {
            adjustedHour = 12;
        }
    } else {
        formatString = @"%ld:%@";
    }
    return [NSString stringWithFormat:formatString, adjustedHour, minuteText];
}

- (instancetype)init
{
    self = [self initWithDictionary:nil];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        _editable = [dict[SENAlarmEditableKey] boolValue];
        _hour = [dict[SENAlarmHourKey] unsignedIntegerValue];
        _identifier = dict[SENAlarmIdentifierKey] ?: [[[NSUUID alloc] init] UUIDString];
        _minute = [dict[SENAlarmMinuteKey] unsignedIntegerValue];
        _on = [dict[SENAlarmOnKey] boolValue];
        _repeatFlags = [self repeatFlagsFromDays:dict[SENAlarmRepeatKey]];
        _smartAlarm = [dict[SENAlarmSmartKey] boolValue];
        _soundName = dict[SENAlarmSoundNameKey];
    }
    return self;
}

- (NSString*)localizedValue
{
    struct SENAlarmTime time;
    time.hour = self.hour;
    time.minute = self.minute;
    return [SENAlarm localizedValueForTime:time];
}

- (NSUInteger)repeatFlagsFromDays:(NSArray*)days
{
    NSUInteger repeatFlags = 0;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayMonday)])
        repeatFlags |= SENAlarmRepeatMonday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayTuesday)])
        repeatFlags |= SENAlarmRepeatTuesday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayWednesday)])
        repeatFlags |= SENAlarmRepeatWednesday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayThursday)])
        repeatFlags |= SENAlarmRepeatThursday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayFriday)])
        repeatFlags |= SENAlarmRepeatFriday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDaySaturday)])
        repeatFlags |= SENAlarmRepeatSaturday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDaySunday)])
        repeatFlags |= SENAlarmRepeatSunday;

    return repeatFlags;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _editable = [[aDecoder decodeObjectForKey:SENAlarmEditableKey] boolValue];
        _hour = [[aDecoder decodeObjectForKey:SENAlarmHourKey] unsignedIntegerValue];
        _identifier = [aDecoder decodeObjectForKey:SENAlarmIdentifierKey] ?: [[[NSUUID alloc] init] UUIDString];
        _minute = [[aDecoder decodeObjectForKey:SENAlarmMinuteKey] unsignedIntegerValue];
        _on = [[aDecoder decodeObjectForKey:SENAlarmOnKey] boolValue];
        _repeatFlags = [[aDecoder decodeObjectForKey:SENAlarmRepeatKey] unsignedIntegerValue];
        _smartAlarm = [[aDecoder decodeObjectForKey:SENAlarmSmartKey] boolValue];
        _soundName = [aDecoder decodeObjectForKey:SENAlarmSoundNameKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:@([self isOn]) forKey:SENAlarmOnKey];
    [aCoder encodeObject:@([self hour]) forKey:SENAlarmHourKey];
    [aCoder encodeObject:@([self minute]) forKey:SENAlarmMinuteKey];
    [aCoder encodeObject:[self soundName] forKey:SENAlarmSoundNameKey];
    [aCoder encodeObject:[self identifier] forKey:SENAlarmIdentifierKey];
    [aCoder encodeObject:@([self isEditable]) forKey:SENAlarmEditableKey];
    [aCoder encodeObject:@([self repeatFlags]) forKey:SENAlarmRepeatKey];
    [aCoder encodeObject:@([self isSmartAlarm]) forKey:SENAlarmSmartKey];
}

- (NSUInteger)hash
{
    return [self.identifier hash];
}

- (BOOL)isEqual:(SENAlarm*)alarm
{
    if (![alarm isKindOfClass:[SENAlarm class]])
        return NO;

    return [self.identifier isEqualToString:alarm.identifier];
}

#pragma mark - updating time

- (struct SENAlarmTime)timeByAddingMinutes:(NSInteger)minutes
{
    struct SENAlarmTime alarmTime;
    if (minutes == 0) {
        alarmTime.hour = self.hour;
        alarmTime.minute = self.minute;
        return alarmTime;
    }

    NSInteger addedHours = minutes / 60;
    NSInteger addedMinutes = minutes % 60;
    NSInteger hour = self.hour + addedHours;
    NSInteger minute = self.minute + addedMinutes;

    if (minutes > 0) {
        if (minute > 59) {
            minute -= 60;
            hour += 1;
        }
    } else {
        if (minute < 0) {
            minute += 60;
            hour -= 1;
        }
    }
    hour %= 24;

    if (hour < 0) {
        hour += 24;
    }
    alarmTime.hour = hour;
    alarmTime.minute = minute;
    return alarmTime;
}

- (void)incrementAlarmTimeByMinutes:(NSInteger)minutes
{
    struct SENAlarmTime alarmTime = [self timeByAddingMinutes:minutes];
    self.hour = alarmTime.hour;
    self.minute = alarmTime.minute;
    [self save];
}

#pragma mark - persistence

- (void)save
{
    [SENKeyedArchiver setObject:self forKey:self.identifier inCollection:NSStringFromClass([SENAlarm class])];
}

- (void)delete
{
    [SENKeyedArchiver removeAllObjectsForKey:self.identifier inCollection:NSStringFromClass([SENAlarm class])];
}

- (void)setSoundName:(NSString*)soundName
{
    if (![soundName isEqualToString:_soundName]) {
        _soundName = soundName;
        [self save];
    }
}

- (void)setOn:(BOOL)on
{
    if (on != _on) {
        _on = on;
        [self save];
    }
}

- (void)setRepeatFlags:(NSUInteger)repeatFlags
{
    if (_repeatFlags != repeatFlags) {
        _repeatFlags = repeatFlags;
        [self save];
    }
}

- (void)setSmartAlarm:(BOOL)smartAlarm
{
    if (_smartAlarm != smartAlarm) {
        _smartAlarm = smartAlarm;
        [self save];
    }
}

@end
