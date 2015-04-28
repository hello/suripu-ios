
#import "SENSleepResult.h"
#import "SENKeyedArchiver.h"

NSInteger const SENSleepResultSentinelValue = -1;

static NSDate* SENSleepResultDateFromTimestamp(NSNumber* timestampMillis)
{
    return [NSDate dateWithTimeIntervalSince1970:[timestampMillis doubleValue] / 1000];
}

static NSString* const SENSleepResultSegmentSensorName = @"name";

@interface SENSleepResult ()

/**
 *  Storage key for sleep result on a given date
 *
 *  @param date date for night of sleep of the data
 *
 *  @return unique key for a given date
 */
+ (NSString*)retrievalKeyForDate:(NSDate*)date;

/**
 *  Storage key
 *
 *  @return unique key
 */
- (NSString*)retrievalKey;
@end

@implementation SENSleepResult

static NSString* const SENSleepResultDate = @"date";
static NSString* const SENSleepResultScore = @"score";
static NSString* const SENSleepResultMessage = @"message";
static NSString* const SENSleepResultSegments = @"segments";
static NSString* const SENSleepResultSensorInsights = @"insights";
static NSString* const SENSleepResultStatistics = @"statistics";
static NSString* const SENSleepResultRetrievalKeyFormat = @"SleepResult-%ld-%ld-%ld";
static NSString* const SENSleepResultDateFormat = @"yyyy-MM-dd";

+ (NSDateFormatter*)dateFormatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = SENSleepResultDateFormat;
    });
    return formatter;
}

+ (NSString*)retrievalKeyForDate:(NSDate*)date
{
    if (!date)
        return nil;

    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                               fromDate:date];
    return [NSString stringWithFormat:SENSleepResultRetrievalKeyFormat, (long)components.day, (long)components.month, (long)components.year];
}

+ (instancetype)sleepResultForDate:(NSDate*)date
{
    if (!date)
        return nil;

    SENSleepResult* result = [SENKeyedArchiver objectsForKey:[self retrievalKeyForDate:date]
                                                inCollection:NSStringFromClass([self class])];
    if (!result) {
        result = [[SENSleepResult alloc] init];
        result.date = date;
    }
    return result;
}

- (instancetype)initWithDictionary:(NSDictionary*)sleepData
{
    if (self = [super init]) {
        _date = SENSleepResultDateFromTimestamp(sleepData[SENSleepResultDate]);
        _score = sleepData[SENSleepResultScore];
        _message = sleepData[SENSleepResultMessage];
        _segments = [self parseSegmentsFromArray:sleepData[SENSleepResultSegments]];
        _sensorInsights = [self parseSensorInsightsFromArray:sleepData[SENSleepResultSensorInsights]];
        _statistics = [self parseStatisticsFromDictionary:sleepData[SENSleepResultStatistics]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _date = [aDecoder decodeObjectForKey:SENSleepResultDate];
        _score = [aDecoder decodeObjectForKey:SENSleepResultScore];
        _message = [aDecoder decodeObjectForKey:SENSleepResultMessage];
        _segments = [aDecoder decodeObjectForKey:SENSleepResultSegments];
        _sensorInsights = [aDecoder decodeObjectForKey:SENSleepResultSensorInsights];
        _statistics = [aDecoder decodeObjectForKey:SENSleepResultStatistics];
    }
    return self;
}

- (NSString*)description
{
    static NSString* const SENSleepResultDescriptionFormat = @"<SENSleepResult @key=%@ @score=%@>";
    return [NSString stringWithFormat:SENSleepResultDescriptionFormat, [self retrievalKey], self.score];
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_date forKey:SENSleepResultDate];
    [aCoder encodeObject:_score forKey:SENSleepResultScore];
    [aCoder encodeObject:_message forKey:SENSleepResultMessage];
    [aCoder encodeObject:_segments forKey:SENSleepResultSegments];
    [aCoder encodeObject:_sensorInsights forKey:SENSleepResultSensorInsights];
    [aCoder encodeObject:_statistics forKey:SENSleepResultStatistics];
}

- (BOOL)updateWithDictionary:(NSDictionary*)data
{
    BOOL changed = NO;
    if (data[SENSleepResultDate]) {
        NSDate* date = [[[self class] dateFormatter] dateFromString:data[SENSleepResultDate]];
        if (![date isEqual:self.date]) {
            self.date = date;
            changed = YES;
        }
    }
    if (data[SENSleepResultMessage] && ![self.message isEqual:data[SENSleepResultMessage]]) {
        self.message = data[SENSleepResultMessage];
        changed = YES;
    }
    if (data[SENSleepResultScore] && ![self.score isEqual:data[SENSleepResultScore]]) {
        self.score = data[SENSleepResultScore];
        changed = YES;
    }
    if (data[SENSleepResultSegments]) {
        NSArray* segments = [self parseSegmentsFromArray:data[SENSleepResultSegments]];
        if (![self.segments isEqual:segments]) {
            self.segments = segments;
            changed = YES;
        }
    }
    if (data[SENSleepResultSensorInsights]) {
        NSArray* insights = [self parseSensorInsightsFromArray:data[SENSleepResultSensorInsights]];
        if (![self.sensorInsights isEqual:insights]) {
            self.sensorInsights = insights;
            changed = YES;
        }
    }
    if (data[SENSleepResultStatistics]) {
        NSArray* stats = [self parseStatisticsFromDictionary:data[SENSleepResultStatistics]];
        if (![self.statistics isEqual:stats]) {
            self.statistics = stats;
            changed = YES;
        }
    }
    return changed;
}

- (NSString*)retrievalKey
{
    return [[self class] retrievalKeyForDate:self.date];
}

- (NSArray*)parseStatisticsFromDictionary:(NSDictionary*)statisticData
{
    if (![statisticData isKindOfClass:[NSDictionary class]])
        return nil;
    __block NSMutableArray* stats = [[NSMutableArray alloc] initWithCapacity:statisticData.count];
    [statisticData enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSNumber* value, BOOL* stop) {
        if ([name isKindOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]) {
            SENSleepResultStatistic* stat = [[SENSleepResultStatistic alloc] initWithName:name value:value];
            if (stat)
                [stats addObject:stat];
        }
    }];
    return stats;
}

- (NSArray*)parseSegmentsFromArray:(NSArray*)segmentsData
{
    NSMutableArray* segments = [[NSMutableArray alloc] initWithCapacity:[segmentsData count]];
    for (NSDictionary* segmentData in segmentsData) {
        SENSleepResultSegment* segment = [[SENSleepResultSegment alloc] initWithDictionary:segmentData];
        if (segment)
            [segments addObject:segment];
    }
    return segments;
}

- (NSArray*)parseSensorInsightsFromArray:(NSArray*)insightData
{
    __block NSMutableArray* insights = [[NSMutableArray alloc] initWithCapacity:insightData.count];
    for (NSDictionary* data in insightData) {
        SENSleepResultSensorInsight* insight = [[SENSleepResultSensorInsight alloc] initWithDictionary:data];
        if (insight)
            [insights addObject:insight];
    }
    return insights;
}

- (void)save
{
    [SENKeyedArchiver setObject:self forKey:[self retrievalKey] inCollection:NSStringFromClass([SENSleepResult class])];
}

- (BOOL)isEqual:(SENSleepResult*)object
{
    if (![object isKindOfClass:[SENSleepResult class]])
        return NO;

    return ((self.date && [self.date isEqual:object.date]) || (!self.date && !object.date))
        && ((self.sensorInsights && [self.sensorInsights isEqualToArray:object.sensorInsights]) || (!self.sensorInsights && !object.sensorInsights))
        && ((self.segments && [self.segments isEqualToArray:object.segments]) || (!self.segments && !object.segments))
        && ((self.statistics && [self.statistics isEqualToArray:object.statistics]) || (!self.statistics && !object.statistics))
        && ((self.score && [self.score isEqual:object.score]) || (!self.score && !object.score))
        && ((self.message && [self.message isEqual:object.message]) || (!self.message && !object.message));
}

- (NSUInteger)hash
{
    return [self.retrievalKey hash];
}

@end

@implementation SENSleepResultSound

static NSString* const SENSleepResultSoundURL = @"url";
static NSString* const SENSleepResultSoundDuration = @"duration_millis";

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    if (!data)
        return nil;
    if (self = [super init]) {
        _URLPath = data[SENSleepResultSoundURL];
        _durationMillis = [data[SENSleepResultSoundDuration] longValue];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _URLPath = [aDecoder decodeObjectForKey:SENSleepResultSoundURL];
        _durationMillis = [[aDecoder decodeObjectForKey:SENSleepResultSoundDuration] longValue];
    }
    return self;
}

- (NSString*)description
{
    static NSString* const SENSleepResultSoundDescriptionFormat = @"<SENSleepResultSound @URLPath=%@ @durationMillis=%ld>";
    return [NSString stringWithFormat:SENSleepResultSoundDescriptionFormat, self.URLPath, self.durationMillis];
}

- (BOOL)isEqual:(SENSleepResultSound*)object
{
    if (![object isKindOfClass:[SENSleepResultSound class]])
        return NO;
    return ((self.URLPath && [self.URLPath isEqual:object.URLPath]) || (!self.URLPath && !object.URLPath))
        && self.durationMillis == object.durationMillis;
}

- (NSUInteger)hash
{
    return [self.URLPath hash] + self.durationMillis;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.URLPath forKey:SENSleepResultSoundURL];
    [aCoder encodeObject:@(self.durationMillis) forKey:SENSleepResultSoundDuration];
}

- (BOOL)updateWithDictionary:(NSDictionary*)data
{
    BOOL changed = NO;
    if (data[SENSleepResultSoundURL] && ![self.URLPath isEqual:data[SENSleepResultSoundURL]]) {
        changed = YES;
        self.URLPath = data[SENSleepResultSoundURL];
    }

    if (data[SENSleepResultSoundDuration]) {
        double duration = [data[SENSleepResultSoundDuration] longValue];
        if (self.durationMillis != duration) {
            self.durationMillis = duration;
            changed = YES;
        }
    }
    return changed;
}

@end

@implementation SENSleepResultSegment

NSString* const SENSleepResultSegmentEventTypeWakeUp = @"WAKE_UP";
NSString* const SENSleepResultSegmentEventTypeSleep = @"SLEEP";

static NSString* const SENSleepResultSegmentServerID = @"id";
static NSString* const SENSleepResultSegmentTimestamp = @"timestamp";
static NSString* const SENSleepResultSegmentDuration = @"duration";
static NSString* const SENSleepResultSegmentEventType = @"event_type";
static NSString* const SENSleepResultSegmentMessage = @"message";
static NSString* const SENSleepResultSegmentSleepDepth = @"sleep_depth";
static NSString* const SENSleepResultSegmentTimezoneOffset = @"offset_millis";
static NSString* const SENSleepResultSegmentSound = @"sound";

- (instancetype)initWithDictionary:(NSDictionary*)segmentData
{
    if (self = [super init]) {
        _serverID = segmentData[SENSleepResultSegmentServerID];
        _date = SENSleepResultDateFromTimestamp(segmentData[SENSleepResultSegmentTimestamp]);
        _duration = segmentData[SENSleepResultSegmentDuration];
        _message = segmentData[SENSleepResultSegmentMessage];
        _eventType = segmentData[SENSleepResultSegmentEventType];
        _sleepDepth = [segmentData[SENSleepResultSegmentSleepDepth] integerValue];
        _sound = [[SENSleepResultSound alloc] initWithDictionary:segmentData[SENSleepResultSegmentSound]];
        _timezone = [NSTimeZone timeZoneForSecondsFromGMT:[segmentData[SENSleepResultSegmentTimezoneOffset] doubleValue] / 1000];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _serverID = [aDecoder decodeObjectForKey:SENSleepResultSegmentServerID];
        _date = [aDecoder decodeObjectForKey:SENSleepResultSegmentTimestamp];
        _duration = [aDecoder decodeObjectForKey:SENSleepResultSegmentDuration];
        _message = [aDecoder decodeObjectForKey:SENSleepResultSegmentMessage];
        _eventType = [aDecoder decodeObjectForKey:SENSleepResultSegmentEventType];
        _sleepDepth = [[aDecoder decodeObjectForKey:SENSleepResultSegmentSleepDepth] integerValue];
        _sound = [aDecoder decodeObjectForKey:SENSleepResultSegmentSound];
        _timezone = [aDecoder decodeObjectForKey:SENSleepResultSegmentTimezoneOffset];
    }
    return self;
}

- (NSString*)description
{
    static NSString* const SENSleepResultSegmentDescriptionFormat = @"<SENSleepResultSegment @sleepDepth=%ld @duration=%@ @eventType=%@>";
    return [NSString stringWithFormat:SENSleepResultSegmentDescriptionFormat, (long)self.sleepDepth, self.duration, self.eventType];
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.serverID forKey:SENSleepResultSegmentServerID];
    [aCoder encodeObject:self.date forKey:SENSleepResultSegmentTimestamp];
    [aCoder encodeObject:self.duration forKey:SENSleepResultSegmentDuration];
    [aCoder encodeObject:self.message forKey:SENSleepResultSegmentMessage];
    [aCoder encodeObject:self.eventType forKey:SENSleepResultSegmentEventType];
    [aCoder encodeObject:@(self.sleepDepth) forKey:SENSleepResultSegmentSleepDepth];
    [aCoder encodeObject:self.sound forKey:SENSleepResultSegmentSound];
    [aCoder encodeObject:self.timezone forKey:SENSleepResultSegmentTimezoneOffset];
}

- (BOOL)isEqual:(SENSleepResultSegment*)object
{
    if (![object isKindOfClass:[SENSleepResultSegment class]])
        return NO;
    return ((self.serverID && [self.serverID isEqual:object.serverID]) || (!self.serverID && !object.serverID))
        && ((self.date && [self.date isEqual:object.date]) || (!self.date && !object.date))
        && ((self.duration && [self.duration isEqual:object.duration]) || (!self.duration && !object.duration))
        && ((self.message && [self.message isEqual:object.message]) || (!self.message && !object.message))
        && ((self.eventType && [self.eventType isEqual:object.eventType]) || (!self.eventType && !object.eventType))
        && ((self.sound && [self.sound isEqual:object.sound]) || (!self.sound && !object.sound))
        && ((self.timezone && [self.timezone isEqual:object.timezone]) || (!self.timezone && !object.timezone))
        && self.sleepDepth == object.sleepDepth;
}

- (NSUInteger)hash
{
    return [self.serverID hash];
}

- (BOOL)updateWithDictionary:(NSDictionary*)data
{
    BOOL changed = NO;
    if (data[SENSleepResultSegmentServerID] && ![self.serverID isEqual:data[SENSleepResultSegmentServerID]]) {
        self.serverID = data[SENSleepResultSegmentServerID];
        changed = YES;
    }
    if (data[SENSleepResultSegmentTimestamp]) {
        NSDate* date = SENSleepResultDateFromTimestamp(data[SENSleepResultSegmentTimestamp]);
        if (![self.date isEqual:date]) {
            self.date = date;
            changed = YES;
        }
    }
    if (data[SENSleepResultSegmentDuration] && ![self.duration isEqual:data[SENSleepResultSegmentDuration]]) {
        self.duration = data[SENSleepResultSegmentDuration];
        changed = YES;
    }
    if (data[SENSleepResultSegmentMessage] && ![self.message isEqual:data[SENSleepResultSegmentMessage]]) {
        self.message = data[SENSleepResultSegmentMessage];
        changed = YES;
    }
    if (data[SENSleepResultSegmentEventType] && ![self.eventType isEqual:data[SENSleepResultSegmentEventType]]) {
        self.eventType = data[SENSleepResultSegmentEventType];
        changed = YES;
    }
    if (data[SENSleepResultSegmentSleepDepth]) {
        NSInteger sleepDepth = [data[SENSleepResultSegmentSleepDepth] integerValue];
        if (self.sleepDepth != sleepDepth) {
            self.sleepDepth = sleepDepth;
            changed = YES;
        }
    }
    if (data[SENSleepResultSegmentTimezoneOffset]) {
        NSTimeInterval secondsFromGMT = [data[SENSleepResultSegmentTimezoneOffset] doubleValue] / 1000;
        NSTimeZone* zone = [NSTimeZone timeZoneForSecondsFromGMT:secondsFromGMT];
        if (![self.timezone isEqual:zone]) {
            self.timezone = zone;
            changed = YES;
        }
    }
    if (data[SENSleepResultSegmentSound]) {
        SENSleepResultSound* sound = [[SENSleepResultSound alloc] initWithDictionary:data[SENSleepResultSegmentSound]];
        if (![self.sound isEqual:sound]) {
            self.sound = sound;
            changed = YES;
        }
    }
    return changed;
}

@end

@implementation SENSleepResultStatistic

static NSString* const SENSleepResultStatisticNameKey = @"name";
static NSString* const SENSleepResultStatisticValueKey = @"value";
static NSString* const SENSleepResultStatisticTypeKey = @"type";

static NSString* const SENSleepResultStatisticNameSoundSleep = @"sound_sleep";
static NSString* const SENSleepResultStatisticNameTotalSleep = @"total_sleep";
static NSString* const SENSleepResultStatisticNameTimesAwake = @"times_awake";
static NSString* const SENSleepResultStatisticNameTimeToSleep = @"time_to_sleep";

+ (SENSleepResultStatisticType)typeFromName:(NSString*)name
{
    if ([name isKindOfClass:[NSString class]]) {
        if ([name isEqualToString:SENSleepResultStatisticNameSoundSleep])
            return SENSleepResultStatisticTypeSoundDuration;
        if ([name isEqualToString:SENSleepResultStatisticNameTotalSleep])
            return SENSleepResultStatisticTypeTotalDuration;
        if ([name isEqualToString:SENSleepResultStatisticNameTimesAwake])
            return SENSleepResultStatisticTypeTimesAwake;
        if ([name isEqualToString:SENSleepResultStatisticNameTimeToSleep])
            return SENSleepResultStatisticTypeTimeToSleep;
    }

    return SENSleepResultStatisticTypeUnknown;
}

- (instancetype)initWithName:(NSString*)name value:(NSNumber*)value
{
    if (self = [super init]) {
        if ([name isKindOfClass:[NSString class]])
            _name = name;
        if ([value isKindOfClass:[NSNumber class]] && [value doubleValue] != SENSleepResultSentinelValue)
            _value = value;
        _type = [SENSleepResultStatistic typeFromName:name];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:SENSleepResultStatisticNameKey];
        _value = [aDecoder decodeObjectForKey:SENSleepResultStatisticValueKey];
        _type = [aDecoder decodeIntegerForKey:SENSleepResultStatisticTypeKey];
    }
    return self;
}

- (NSString*)description
{
    static NSString* const SENSleepResultStatDescriptionFormat = @"<SENSleepResultStatistic @name=%@ @value=%@>";
    return [NSString stringWithFormat:SENSleepResultStatDescriptionFormat, self.name, self.value];
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.name forKey:SENSleepResultStatisticNameKey];
    [aCoder encodeObject:self.value forKey:SENSleepResultStatisticValueKey];
    [aCoder encodeInteger:self.type forKey:SENSleepResultStatisticTypeKey];
}

- (BOOL)isEqual:(SENSleepResultStatistic*)object
{
    if (![object isKindOfClass:[SENSleepResultStatistic class]])
        return NO;
    return ((self.name && [self.name isEqual:object.name]) || (!self.name && !object.name))
        && ((self.value && [self.value isEqual:object.value]) || (!self.value && !object.value))
        && self.type == object.type;
}

- (NSUInteger)hash
{
    return [self.name hash] + [self.value hash] + self.type;
}

@end

@implementation SENSleepResultSensorInsight

static NSString* const SENSleepResultSensorInsightName = @"sensor";
static NSString* const SENSleepResultSensorInsightMessage = @"message";
static NSString* const SENSleepResultSensorInsightCondition = @"condition";

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    if (self = [super init]) {
        _name = data[SENSleepResultSensorInsightName];
        _message = data[SENSleepResultSensorInsightMessage];
        _condition = [SENSensor conditionFromValue:data[SENSleepResultSensorInsightCondition]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)decoder
{
    if (self = [super init]) {
        _name = [decoder decodeObjectForKey:SENSleepResultSensorInsightName];
        _message = [decoder decodeObjectForKey:SENSleepResultSensorInsightMessage];
        _condition = [[decoder decodeObjectForKey:SENSleepResultSensorInsightCondition] integerValue];
    }
    return self;
}

- (NSString*)description
{
    static NSString* const SENSleepResultInsightDescriptionFormat = @"<SENSleepResultSensorInsight @name=%@ @message=%@>";
    return [NSString stringWithFormat:SENSleepResultInsightDescriptionFormat, self.name, self.message];
}

- (BOOL)isEqual:(SENSleepResultSensorInsight*)object
{
    if (![object isKindOfClass:[SENSleepResultSensorInsight class]])
        return NO;
    return ((self.name && [self.name isEqual:object.name]) || (!self.name && !object.name))
        && ((self.message && [self.message isEqual:object.message]) || (!self.message && !object.message))
        && self.condition == object.condition;
}

- (NSUInteger)hash
{
    return [self.name hash] + [self.message hash];
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.name forKey:SENSleepResultSensorInsightName];
    [aCoder encodeObject:self.message forKey:SENSleepResultSensorInsightMessage];
    [aCoder encodeObject:@(self.condition) forKey:SENSleepResultSensorInsightCondition];
}

- (BOOL)updateWithDictionary:(NSDictionary*)data
{
    BOOL changed = NO;
    if (data[SENSleepResultSensorInsightName] && ![self.name isEqual:data[SENSleepResultSensorInsightName]]) {
        self.name = data[SENSleepResultSensorInsightName];
        changed = YES;
    }
    if (data[SENSleepResultSensorInsightMessage] && ![self.message isEqual:data[SENSleepResultSensorInsightMessage]]) {
        self.message = data[SENSleepResultSensorInsightMessage];
        changed = YES;
    }
    if (data[SENSleepResultSensorInsightCondition]) {
        SENSensorCondition condition = [SENSensor conditionFromValue:data[SENSleepResultSensorInsightCondition]];
        if (self.condition != condition) {
            self.condition = condition;
            changed = YES;
        }
    }
    return changed;
}

@end
