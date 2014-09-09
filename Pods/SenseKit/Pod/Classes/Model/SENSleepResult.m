
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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_date forKey:SENSleepResultDate];
    [aCoder encodeObject:_score forKey:SENSleepResultScore];
    [aCoder encodeObject:_message forKey:SENSleepResultMessage];
    [aCoder encodeObject:_segments forKey:SENSleepResultSegments];
}

- (void)updateWithDictionary:(NSDictionary*)data
{
    if (data[SENSleepResultDate])
        self.date = SENSleepResultDateFromTimestamp(data[SENSleepResultDate]);
    if (data[SENSleepResultMessage])
        self.message = data[SENSleepResultMessage];
    if (data[SENSleepResultScore])
        self.score = data[SENSleepResultScore];
    if (data[SENSleepResultSegments])
        self.segments = [self parseSegmentsFromArray:data[SENSleepResultSegments]];
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

- (void)save
{
    [SENKeyedArchiver setObject:self forKey:[self retrievalKey] inCollection:NSStringFromClass([SENSleepResult class])];
}

@end

@implementation SENSleepResultSegment

static NSString* const SENSleepResultSegmentServerID = @"id";
static NSString* const SENSleepResultSegmentDate = @"date";
static NSString* const SENSleepResultSegmentDuration = @"duration";
static NSString* const SENSleepResultSegmentEventType = @"event_type";
static NSString* const SENSleepResultSegmentMessage = @"message";
static NSString* const SENSleepResultSegmentSleepDepth = @"sleep_depth";
static NSString* const SENSleepResultSegmentSensors = @"sensors";

- (instancetype)initWithDictionary:(NSDictionary*)segmentData
{
    if (self = [super init]) {
        _serverID = segmentData[SENSleepResultSegmentServerID];
        _date = SENSleepResultDateFromTimestamp(segmentData[SENSleepResultSegmentDate]);
        _duration = segmentData[SENSleepResultSegmentDuration];
        _message = segmentData[SENSleepResultSegmentMessage];
        _eventType = segmentData[SENSleepResultSegmentEventType];
        _sleepDepth = [self parseSleepDepthFromValue:segmentData[SENSleepResultSegmentSleepDepth]];
        _sensors = [self parseSensorsFromDictionary:segmentData[SENSleepResultSegmentSensors]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _serverID = [aDecoder decodeObjectForKey:SENSleepResultSegmentServerID];
        _date = [aDecoder decodeObjectForKey:SENSleepResultSegmentDate];
        _duration = [aDecoder decodeObjectForKey:SENSleepResultSegmentDuration];
        _message = [aDecoder decodeObjectForKey:SENSleepResultSegmentMessage];
        _eventType = [aDecoder decodeObjectForKey:SENSleepResultSegmentEventType];
        _sleepDepth = [[aDecoder decodeObjectForKey:SENSleepResultSegmentSleepDepth] integerValue];
        _sensors = [aDecoder decodeObjectForKey:SENSleepResultSegmentSensors];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_serverID forKey:SENSleepResultSegmentServerID];
    [aCoder encodeObject:_date forKey:SENSleepResultSegmentDate];
    [aCoder encodeObject:_duration forKey:SENSleepResultSegmentDuration];
    [aCoder encodeObject:_message forKey:SENSleepResultSegmentMessage];
    [aCoder encodeObject:_eventType forKey:SENSleepResultSegmentEventType];
    [aCoder encodeObject:@(_sleepDepth) forKey:SENSleepResultSegmentSleepDepth];
    [aCoder encodeObject:_sensors forKey:SENSleepResultSegmentSensors];
}

- (void)updateWithDictionary:(NSDictionary*)data
{
    if (data[SENSleepResultSegmentServerID])
        self.serverID = data[SENSleepResultSegmentServerID];
    if (data[SENSleepResultSegmentDate])
        self.date = SENSleepResultDateFromTimestamp(data[SENSleepResultSegmentDate]);
    if (data[SENSleepResultSegmentDuration])
        self.duration = data[SENSleepResultSegmentDuration];
    if (data[SENSleepResultSegmentMessage])
        self.message = data[SENSleepResultSegmentMessage];
    if (data[SENSleepResultSegmentEventType])
        self.eventType = data[SENSleepResultSegmentEventType];
    if (data[SENSleepResultSegmentSleepDepth])
        self.sleepDepth = [self parseSleepDepthFromValue:data[SENSleepResultSegmentSleepDepth]];
    if (data[SENSleepResultSegmentSensors])
        self.sensors = [self parseSensorsFromDictionary:data[SENSleepResultSegments]];
}

- (NSArray*)parseSensorsFromDictionary:(NSDictionary*)sensorsData
{
    NSMutableArray* sensors = [[NSMutableArray alloc] initWithCapacity:[sensorsData count]];
    [sensorsData enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        NSMutableDictionary* sensorData = [obj mutableCopy];
        sensorData[SENSleepResultSegmentSensorName] = key;
        SENSleepResultSegmentSensor* sensor = [[SENSleepResultSegmentSensor alloc] initWithDictionary:sensorData];
        if (sensor)
            [sensors addObject:sensor];
    }];
    return sensors;
}

- (NSInteger)parseSleepDepthFromValue:(NSNumber*)value
{
    return MAX(0, MIN(SENSleepResultSegmentDepthDeep, [value integerValue]));
}

@end

@implementation SENSleepResultSegmentSensor

static NSString* const SENSleepResultSegmentSensorValue = @"value";
static NSString* const SENSleepResultSegmentSensorUnit = @"unit";

- (instancetype)initWithDictionary:(NSDictionary*)sensorData
{
    if (self = [super init]) {
        _name = sensorData[SENSleepResultSegmentSensorName];
        _value = sensorData[SENSleepResultSegmentSensorValue];
        _unit = sensorData[SENSleepResultSegmentSensorUnit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:SENSleepResultSegmentSensorName];
        _value = [aDecoder decodeObjectForKey:SENSleepResultSegmentSensorValue];
        _unit = [aDecoder decodeObjectForKey:SENSleepResultSegmentSensorUnit];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_name forKey:SENSleepResultSegmentSensorName];
    [aCoder encodeObject:_value forKey:SENSleepResultSegmentSensorValue];
    [aCoder encodeObject:_unit forKey:SENSleepResultSegmentSensorUnit];
}

- (void)updateWithDictionary:(NSDictionary*)data
{
    if (data[SENSleepResultSegmentSensorName])
        self.name = data[SENSleepResultSegmentSensorName];
    if (data[SENSleepResultSegmentSensorValue])
        self.value = data[SENSleepResultSegmentSensorValue];
    if (data[SENSleepResultSegmentSensorUnit])
        self.unit = data[SENSleepResultSegmentSensorUnit];
}

@end