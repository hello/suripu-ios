
#import "SENSleepResult.h"
#import "SENKeyedArchiver.h"

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
static NSString* const SENSleepResultRetrievalKeyFormat = @"SleepResult-%ld-%ld-%ld";

+ (NSString*)retrievalKeyForDate:(NSDate*)date
{
    if (!date)
        return nil;

    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_date forKey:SENSleepResultDate];
    [aCoder encodeObject:_score forKey:SENSleepResultScore];
    [aCoder encodeObject:_message forKey:SENSleepResultMessage];
    [aCoder encodeObject:_segments forKey:SENSleepResultSegments];
    [aCoder encodeObject:_sensorInsights forKey:SENSleepResultSensorInsights];
}

- (void)updateWithDictionary:(NSDictionary*)data
{
    if (data[SENSleepResultMessage])
        self.message = data[SENSleepResultMessage];
    if (data[SENSleepResultScore])
        self.score = data[SENSleepResultScore];
    if (data[SENSleepResultSegments])
        self.segments = [self parseSegmentsFromArray:data[SENSleepResultSegments]];
    if (data[SENSleepResultSensorInsights])
        self.sensorInsights = [self parseSensorInsightsFromArray:data[SENSleepResultSensorInsights]];
}

- (NSString*)retrievalKey
{
    return [[self class] retrievalKeyForDate:self.date];
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

@end

@implementation SENSleepResultSegment

static NSString* const SENSleepResultSegmentServerID = @"id";
static NSString* const SENSleepResultSegmentTimestamp = @"timestamp";
static NSString* const SENSleepResultSegmentDuration = @"duration";
static NSString* const SENSleepResultSegmentEventType = @"event_type";
static NSString* const SENSleepResultSegmentMessage = @"message";
static NSString* const SENSleepResultSegmentSleepDepth = @"sleep_depth";

- (instancetype)initWithDictionary:(NSDictionary*)segmentData
{
    if (self = [super init]) {
        _serverID = segmentData[SENSleepResultSegmentServerID];
        _date = SENSleepResultDateFromTimestamp(segmentData[SENSleepResultSegmentTimestamp]);
        _duration = segmentData[SENSleepResultSegmentDuration];
        _message = segmentData[SENSleepResultSegmentMessage];
        _eventType = segmentData[SENSleepResultSegmentEventType];
        _sleepDepth = [segmentData[SENSleepResultSegmentSleepDepth] integerValue];
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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_serverID forKey:SENSleepResultSegmentServerID];
    [aCoder encodeObject:_date forKey:SENSleepResultSegmentTimestamp];
    [aCoder encodeObject:_duration forKey:SENSleepResultSegmentDuration];
    [aCoder encodeObject:_message forKey:SENSleepResultSegmentMessage];
    [aCoder encodeObject:_eventType forKey:SENSleepResultSegmentEventType];
    [aCoder encodeObject:@(_sleepDepth) forKey:SENSleepResultSegmentSleepDepth];
}

- (void)updateWithDictionary:(NSDictionary*)data
{
    if (data[SENSleepResultSegmentServerID])
        self.serverID = data[SENSleepResultSegmentServerID];
    if (data[SENSleepResultSegmentTimestamp])
        self.date = SENSleepResultDateFromTimestamp(data[SENSleepResultSegmentTimestamp]);
    if (data[SENSleepResultSegmentDuration])
        self.duration = data[SENSleepResultSegmentDuration];
    if (data[SENSleepResultSegmentMessage])
        self.message = data[SENSleepResultSegmentMessage];
    if (data[SENSleepResultSegmentEventType])
        self.eventType = data[SENSleepResultSegmentEventType];
    if (data[SENSleepResultSegmentSleepDepth])
        self.sleepDepth = [data[SENSleepResultSegmentSleepDepth] integerValue];
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

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.name forKey:SENSleepResultSensorInsightName];
    [aCoder encodeObject:self.message forKey:SENSleepResultSensorInsightMessage];
    [aCoder encodeObject:@(self.condition) forKey:SENSleepResultSensorInsightCondition];
}

- (void)updateWithDictionary:(NSDictionary*)data
{
    if (data[SENSleepResultSensorInsightName])
        self.name = data[SENSleepResultSensorInsightName];
    if (data[SENSleepResultSensorInsightMessage])
        self.message = data[SENSleepResultSensorInsightMessage];
    if (data[SENSleepResultSensorInsightCondition])
        self.condition = [SENSensor conditionFromValue:data[SENSleepResultSensorInsightCondition]];
}

@end
