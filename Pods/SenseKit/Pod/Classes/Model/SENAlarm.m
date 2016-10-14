
#import "SENAlarm.h"
#import "SENKeyedArchiver.h"
#import "SENPreference.h"
#import "Model.h"

@interface SENAlarmExpansion()

- (NSDictionary*)dictionaryValue;

@end

@implementation SENAlarmExpansion

static NSString* const SENAlarmExpansionIdKey = @"id";
static NSString* const SENAlarmExpansionEnableKey = @"enable";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _expansionId = SENObjectOfClass(data[SENAlarmExpansionIdKey], [NSNumber class]);
        _enable = [SENObjectOfClass(data[SENAlarmExpansionEnableKey], [NSNumber class]) boolValue];
    }
    return self;
}

- (instancetype)initWithExpansionId:(NSNumber *)expansionId enable:(BOOL)enable {
    if (self = [super init]) {
        _expansionId = expansionId;
        _enable = enable;
    }
    return self;
}

- (NSUInteger)hash {
    return [[self expansionId] hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SENAlarmExpansion class]]) {
        return NO;
    }
    
    SENAlarmExpansion* other = object;
    return SENObjectIsEqual([self expansionId], [other expansionId])
        && [self isEnable] == [other isEnable];
}

- (NSDictionary*)dictionaryValue {
    return @{SENAlarmExpansionIdKey : [self expansionId],
             SENAlarmExpansionEnableKey : @([self isEnable])};
}

@end

@interface SENAlarm()

@property (nonatomic, assign) BOOL saved;
@property (nonatomic, getter=isEditable) BOOL editable;

@end

@implementation SENAlarm

static NSString* const SENAlarmSoundKey = @"sound";
static NSString* const SENAlarmSoundNameKey = @"name";
static NSString* const SENAlarmSoundIDKey = @"id";
static NSString* const SENAlarmSoundIDEncodingKey = @"sound_id";
static NSString* const SENAlarmOnKey = @"enabled";
static NSString* const SENAlarmSmartKey = @"smart";
static NSString* const SENAlarmEditableKey = @"editable";
static NSString* const SENAlarmHourKey = @"hour";
static NSString* const SENAlarmMinuteKey = @"minute";
static NSString* const SENAlarmRepeatKey = @"day_of_week";
static NSString* const SENAlarmIdentifierKey = @"id";
static NSString* const SENAlarmSourceKey = @"source";
static NSString* const SENAlarmExpansionsKey = @"expansions";
static NSString* const SENALarmSourceValueVoice = @"VOICE_SERVICE";
static NSString* const SENALarmSourceValueOther = @"OTHER";
static NSString* const SENALarmSourceValueMobile = @"MOBILE_APP";

static NSString* const SENAlarmDefaultSoundName = @"None";
static NSUInteger const SENAlarmDefaultHour = 7;
static NSUInteger const SENAlarmDefaultMinute = 30;
static BOOL const SENAlarmDefaultOnState = YES;
static BOOL const SENAlarmDefaultEditableState = YES;
static BOOL const SENAlarmDefaultSmartAlarmState = YES;

+ (SENAlarm*)createDefaultAlarm {
    SENAlarm* alarm = [[self alloc] init];
    alarm.soundName = SENAlarmDefaultSoundName;
    alarm.hour = SENAlarmDefaultHour;
    alarm.minute = SENAlarmDefaultMinute;
    alarm.on = SENAlarmDefaultOnState;
    alarm.editable = SENAlarmDefaultEditableState;
    alarm.smartAlarm = SENAlarmDefaultSmartAlarmState;
    alarm.repeatFlags = 0;
    alarm.saved = NO;
    return alarm;
}

+ (NSDate*)nextRingDateWithHour:(NSUInteger)hour minute:(NSUInteger)minute {
    NSDate* date = [NSDate date];
    NSCalendarUnit flags = (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay);
    NSDateComponents* currentDateComponents = [[NSCalendar autoupdatingCurrentCalendar] components:flags fromDate:date];
    NSInteger minuteOfDay = (currentDateComponents.hour * 60) + currentDateComponents.minute;
    NSInteger alarmMinuteOfDay = (hour * 60) + minute;
    NSDateComponents* diff = [NSDateComponents new];
    diff.minute = alarmMinuteOfDay - minuteOfDay;
    if (alarmMinuteOfDay < minuteOfDay) {
        diff.day = 1;
    }
    return [[NSCalendar autoupdatingCurrentCalendar] dateByAddingComponents:diff toDate:date options:0];
}

+ (NSString*)localizedValueForTime:(struct SENAlarmTime)time {
    long adjustedHour = time.hour;
    NSString* formatString;
    NSString* minuteText = time.minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)time.minute] : [NSString stringWithFormat:@"%ld", (long)time.minute];
    if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
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

- (instancetype)init {
    self = [self initWithDictionary:nil];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super init]) {
        _editable = [dict[SENAlarmEditableKey] boolValue];
        _hour = [dict[SENAlarmHourKey] unsignedIntegerValue];
        NSString* identifier = dict[SENAlarmIdentifierKey];
        _identifier = identifier.length > 0 ? identifier : [[[NSUUID alloc] init] UUIDString];
        _minute = [dict[SENAlarmMinuteKey] unsignedIntegerValue];
        _on = [dict[SENAlarmOnKey] boolValue];
        _repeatFlags = [self repeatFlagsFromDays:dict[SENAlarmRepeatKey]];
        _smartAlarm = [dict[SENAlarmSmartKey] boolValue];
        _soundName = dict[SENAlarmSoundKey][SENAlarmSoundNameKey];
        _soundID = dict[SENAlarmSoundKey][SENAlarmSoundIDKey];
        _saved = YES;
        
        NSArray* expansionObjects = SENObjectOfClass(dict[SENAlarmExpansionsKey], [NSArray class]);
        _expansions = [self expansionsFromRawArray:expansionObjects];
        
        NSString* sourceName = SENObjectOfClass(dict[SENAlarmSourceKey], [NSString class]);
        _source = [self sourceForName:sourceName];
    }
    return self;
}

- (NSArray<SENAlarmExpansion*>*)expansionsFromRawArray:(NSArray*)expansionArray {
    NSMutableArray* expansions = [NSMutableArray arrayWithCapacity:[expansionArray count]];
    for (id expansionObj in expansionArray) {
        if ([expansionObj isKindOfClass:[NSDictionary class]]) {
            [expansions addObject:[[SENAlarmExpansion alloc] initWithDictionary:expansionObj]];
        }
    }
    return expansions;
}

- (SENALarmSource)sourceForName:(NSString*)name {
    NSString* upperName = [name uppercaseString];
    if ([upperName isEqualToString:SENALarmSourceValueVoice]) {
        return SENAlarmSourceVoice;
    } else if ([upperName isEqualToString:SENALarmSourceValueOther]) {
        return SENAlarmSourceOther;
    } else { // default to mobile, since that was the only way to create alarms
        return SENAlarmSourceMobile;
    }
}

- (NSString*)localizedValue {
    struct SENAlarmTime time;
    time.hour = self.hour;
    time.minute = self.minute;
    return [SENAlarm localizedValueForTime:time];
}

- (NSUInteger)repeatFlagsFromDays:(NSArray*)days {
    NSUInteger repeatFlags = 0;
    if ([days containsObject:@(SENALarmRepeatDayValueMonday)])
        repeatFlags |= SENAlarmRepeatMonday;
    if ([days containsObject:@(SENALarmRepeatDayValueTuesday)])
        repeatFlags |= SENAlarmRepeatTuesday;
    if ([days containsObject:@(SENALarmRepeatDayValueWednesday)])
        repeatFlags |= SENAlarmRepeatWednesday;
    if ([days containsObject:@(SENALarmRepeatDayValueThursday)])
        repeatFlags |= SENAlarmRepeatThursday;
    if ([days containsObject:@(SENALarmRepeatDayValueFriday)])
        repeatFlags |= SENAlarmRepeatFriday;
    if ([days containsObject:@(SENALarmRepeatDayValueSaturday)])
        repeatFlags |= SENAlarmRepeatSaturday;
    if ([days containsObject:@(SENALarmRepeatDayValueSunday)])
        repeatFlags |= SENAlarmRepeatSunday;

    return repeatFlags;
}

- (BOOL)isRepeated {
    return self.repeatFlags != 0;
}

- (BOOL)isRepeatedOn:(SENAlarmRepeatDays)days {
    return (self.repeatFlags & days) != 0;
}

- (NSDictionary*)dictionaryValue {
    BOOL repeated = self.repeatFlags != 0;
    NSMutableDictionary* properties = [NSMutableDictionary new];
    
    properties[@"editable"] = @([self isEditable]);
    properties[@"enabled"] = @([self isOn]);
    properties[@"sound"] = @{@"name" : self.soundName ?: @"",
                             @"id" : self.soundID ?: @""};
    
    if (self.identifier.length > 0) {
        properties[@"id"] = self.identifier;
    }
    
    properties[@"hour"] = @(self.hour);
    properties[@"minute"] = @(self.minute);
    properties[@"repeated"] = @(repeated);
    properties[@"smart"] = @([self isSmartAlarm]);
    properties[@"day_of_week"] = [self repeatDays];
    
    if ([self expansions]) {
        NSMutableArray* rawArray = [NSMutableArray arrayWithCapacity:[[self expansions] count]];
        for (SENAlarmExpansion* expansion in [self expansions]) {
            [rawArray addObject:[expansion dictionaryValue]];
        }
        properties[SENAlarmExpansionsKey] = rawArray;
    }
    
    if (!repeated) {
        NSDateComponents* alarmDateComponents = [self dateComponents];
        properties[@"day_of_month"] = @(alarmDateComponents.day);
        properties[@"month"] = @(alarmDateComponents.month);
        properties[@"year"] = @(alarmDateComponents.year);
    }
    
    return properties;
}

- (NSDateComponents*)dateComponents {
    NSCalendarUnit flags = (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay);
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate* nextRingDate = [SENAlarm nextRingDateWithHour:[self hour] minute:[self minute]];
    return [calendar components:flags fromDate:nextRingDate];
}


- (NSArray*)repeatDays {
    NSMutableArray* repeatDays = [[NSMutableArray alloc] initWithCapacity:7];
    if ((self.repeatFlags & SENAlarmRepeatMonday) == SENAlarmRepeatMonday)
        [repeatDays addObject:@(SENALarmRepeatDayValueMonday)];
    if ((self.repeatFlags & SENAlarmRepeatTuesday) == SENAlarmRepeatTuesday)
        [repeatDays addObject:@(SENALarmRepeatDayValueTuesday)];
    if ((self.repeatFlags & SENAlarmRepeatWednesday) == SENAlarmRepeatWednesday)
        [repeatDays addObject:@(SENALarmRepeatDayValueWednesday)];
    if ((self.repeatFlags & SENAlarmRepeatThursday) == SENAlarmRepeatThursday)
        [repeatDays addObject:@(SENALarmRepeatDayValueThursday)];
    if ((self.repeatFlags & SENAlarmRepeatFriday) == SENAlarmRepeatFriday)
        [repeatDays addObject:@(SENALarmRepeatDayValueFriday)];
    if ((self.repeatFlags & SENAlarmRepeatSaturday) == SENAlarmRepeatSaturday)
        [repeatDays addObject:@(SENALarmRepeatDayValueSaturday)];
    if ((self.repeatFlags & SENAlarmRepeatSunday) == SENAlarmRepeatSunday)
        [repeatDays addObject:@(SENALarmRepeatDayValueSunday)];
    
    return repeatDays;
}

- (void)setEnable:(BOOL)enable forExpansionId:(NSNumber*)expansionId {
    NSMutableArray* mutableExpansions = [[self expansions] mutableCopy];
    if (!mutableExpansions) {
        mutableExpansions = [NSMutableArray arrayWithCapacity:2];
    }
    SENAlarmExpansion* alarmExpansion = nil;
    for (SENAlarmExpansion* expansion in mutableExpansions) {
        if ([[expansion expansionId] isEqualToNumber:expansionId]) {
            alarmExpansion = expansion;
            break;
        }
    }
    
    if (alarmExpansion) {
        [alarmExpansion setEnable:enable];
    } else {
        alarmExpansion = [[SENAlarmExpansion alloc] initWithExpansionId:expansionId enable:enable];
        [mutableExpansions addObject:alarmExpansion];
    }
    
    _expansions = mutableExpansions;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super init]) {
        NSString* identifier = [aDecoder decodeObjectForKey:SENAlarmIdentifierKey];
        _editable = [[aDecoder decodeObjectForKey:SENAlarmEditableKey] boolValue];
        _hour = [[aDecoder decodeObjectForKey:SENAlarmHourKey] unsignedIntegerValue];
        _identifier = identifier.length > 0 ? identifier : [[[NSUUID alloc] init] UUIDString];
        _minute = [[aDecoder decodeObjectForKey:SENAlarmMinuteKey] unsignedIntegerValue];
        _on = [[aDecoder decodeObjectForKey:SENAlarmOnKey] boolValue];
        _repeatFlags = [[aDecoder decodeObjectForKey:SENAlarmRepeatKey] unsignedIntegerValue];
        _smartAlarm = [[aDecoder decodeObjectForKey:SENAlarmSmartKey] boolValue];
        _soundName = [aDecoder decodeObjectForKey:SENAlarmSoundNameKey];
        _soundID = [aDecoder decodeObjectForKey:SENAlarmSoundIDEncodingKey];
        _expansions = [aDecoder decodeObjectForKey:SENAlarmExpansionsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:@([self isOn]) forKey:SENAlarmOnKey];
    [aCoder encodeObject:@([self hour]) forKey:SENAlarmHourKey];
    [aCoder encodeObject:@([self minute]) forKey:SENAlarmMinuteKey];
    [aCoder encodeObject:[self soundName] forKey:SENAlarmSoundNameKey];
    [aCoder encodeObject:[self soundID] forKey:SENAlarmSoundIDEncodingKey];
    [aCoder encodeObject:[self identifier] forKey:SENAlarmIdentifierKey];
    [aCoder encodeObject:@([self isEditable]) forKey:SENAlarmEditableKey];
    [aCoder encodeObject:@([self repeatFlags]) forKey:SENAlarmRepeatKey];
    [aCoder encodeObject:@([self isSmartAlarm]) forKey:SENAlarmSmartKey];
    [aCoder encodeObject:[self expansions] forKey:SENAlarmExpansionsKey];
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

- (BOOL)isEqual:(SENAlarm*)alarm {
    if (![alarm isKindOfClass:[SENAlarm class]])
        return NO;

    return [self.identifier isEqualToString:alarm.identifier] && [self isIdenticalToAlarm:alarm];
}

- (BOOL)isIdenticalToAlarm:(SENAlarm *)alarm {
    return self.hour == alarm.hour
        && self.minute == alarm.minute
        && self.repeatFlags == alarm.repeatFlags
        && ((self.soundID && [self.soundID isEqual:alarm.soundID]) || (!self.soundID && !alarm.soundID))
        && ((self.soundName && [self.soundName isEqual:alarm.soundName]) || (!self.soundName && !alarm.soundName))
        && [self isSmartAlarm] == [alarm isSmartAlarm]
        && [self isEditable] == [alarm isEditable]
        && [self isOn] == [alarm isOn]
        && SENObjectIsEqual([self expansions], [alarm expansions]);
}

@end
