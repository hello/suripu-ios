
#import "SENAlarm.h"
#import "SENKeyedArchiver.h"

static NSString* const SENAlarmSoundNameKey = @"sound";
static NSString* const SENAlarmOnKey = @"on";
static NSString* const SENAlarmHourKey = @"hour";
static NSString* const SENAlarmMinuteKey = @"minute";
static NSString* const SENAlarmIdentifierKey = @"identifier";
static NSString* const SENAlarmArchiveKey = @"SENAlarmArchiveKey";

@interface SENAlarm ()
@property (nonatomic, strong) NSString* identifier;
@end

@implementation SENAlarm

+ (SENAlarm*)savedAlarm
{
    SENAlarm* alarm = [[[SENKeyedArchiver objectsForKey:SENAlarmArchiveKey] allObjects] firstObject];
    if (!alarm) {
        NSDictionary* properties = @{
            SENAlarmSoundNameKey : @"None",
            SENAlarmHourKey : @7,
            SENAlarmMinuteKey : @30,
            SENAlarmOnKey : @YES
        };
        alarm = [[SENAlarm alloc] initWithDictionary:properties];
        [alarm save];
    }

    return alarm;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        _on = [dict[SENAlarmOnKey] boolValue];
        _hour = [dict[SENAlarmHourKey] integerValue];
        _minute = [dict[SENAlarmMinuteKey] integerValue];
        _soundName = dict[SENAlarmSoundNameKey];
        _identifier = dict[SENAlarmIdentifierKey] ?: [[[NSUUID alloc] init] UUIDString];
    }
    return self;
}

- (NSString*)localizedValue
{
    NSString* minuteText = self.minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)self.minute] : [NSString stringWithFormat:@"%ld", (long)self.minute];
    return [NSString stringWithFormat:@"%ld:%@", (long)self.hour, minuteText];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _on = [[aDecoder decodeObjectForKey:SENAlarmOnKey] boolValue];
        _hour = [[aDecoder decodeObjectForKey:SENAlarmHourKey] integerValue];
        _minute = [[aDecoder decodeObjectForKey:SENAlarmMinuteKey] integerValue];
        _soundName = [aDecoder decodeObjectForKey:SENAlarmSoundNameKey];
        _identifier = [aDecoder decodeObjectForKey:SENAlarmSoundNameKey] ?: [[[NSUUID alloc] init] UUIDString];
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
    [SENKeyedArchiver setObjects:[NSSet setWithObject:self] forKey:SENAlarmArchiveKey];
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

@end
