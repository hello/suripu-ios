
#import "SENTimeline.h"
#import "SENKeyedArchiver.h"

NSInteger const SENTimelineSentinelValue = -1;

@interface SENTimeline ()

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

@implementation SENTimeline

static NSString* const SENTimelineDate = @"date";
static NSString* const SENTimelineScore = @"score";
static NSString* const SENTimelineScoreCondition = @"score_condition";
static NSString* const SENTimelineMessage = @"message";
static NSString* const SENTimelineSegments = @"events";
static NSString* const SENTimelineMetrics = @"metrics";
static NSString* const SENTimelineRetrievalKeyFormat = @"Timeline-v2-%ld-%ld-%ld";
static NSString* const SENTimelineDateFormat = @"yyyy-MM-dd";

+ (NSDateFormatter*)dateFormatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = SENTimelineDateFormat;
    });
    return formatter;
}

+ (NSString*)retrievalKeyForDate:(NSDate*)date
{
    if (!date)
        return nil;

    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                               fromDate:date];
    return [NSString stringWithFormat:SENTimelineRetrievalKeyFormat, (long)components.day, (long)components.month, (long)components.year];
}

+ (instancetype)timelineForDate:(NSDate*)date
{
    if (!date)
        return nil;

    SENTimeline* result = [SENKeyedArchiver objectsForKey:[self retrievalKeyForDate:date]
                                             inCollection:NSStringFromClass([self class])];
    if (!result) {
        result = [[SENTimeline alloc] init];
        result.date = date;
    }
    return result;
}

- (instancetype)initWithDictionary:(NSDictionary*)sleepData
{
    if (self = [super init]) {
        _date = [[[self class] dateFormatter] dateFromString:sleepData[SENTimelineDate]];
        _score = sleepData[SENTimelineScore];
        _scoreCondition = SENConditionFromString(sleepData[SENTimelineScoreCondition]);
        _message = sleepData[SENTimelineMessage];
        _segments = [self parseSegmentsFromArray:sleepData[SENTimelineSegments]];
        _metrics = [self parseMetricsFromArray:sleepData[SENTimelineMetrics]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _date = [aDecoder decodeObjectForKey:SENTimelineDate];
        _score = [aDecoder decodeObjectForKey:SENTimelineScore];
        _message = [aDecoder decodeObjectForKey:SENTimelineMessage];
        _segments = [aDecoder decodeObjectForKey:SENTimelineSegments];
        _metrics = [aDecoder decodeObjectForKey:SENTimelineMetrics];
        _scoreCondition = [aDecoder decodeIntegerForKey:SENTimelineScoreCondition];
    }
    return self;
}

- (NSString*)description
{
    static NSString* const SENTimelineDescriptionFormat = @"<SENTimeline @key=%@ @score=%@>";
    return [NSString stringWithFormat:SENTimelineDescriptionFormat, [self retrievalKey], self.score];
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_date forKey:SENTimelineDate];
    [aCoder encodeObject:_score forKey:SENTimelineScore];
    [aCoder encodeObject:_message forKey:SENTimelineMessage];
    [aCoder encodeObject:_segments forKey:SENTimelineSegments];
    [aCoder encodeObject:_metrics forKey:SENTimelineMetrics];
    [aCoder encodeInteger:_scoreCondition forKey:SENTimelineScoreCondition];
}

- (BOOL)updateWithDictionary:(NSDictionary*)data
{
    BOOL changed = NO;
    if (data[SENTimelineDate]) {
        NSDate* date = [[[self class] dateFormatter] dateFromString:data[SENTimelineDate]];
        if (![date isEqual:self.date]) {
            self.date = date;
            changed = YES;
        }
    }
    if (data[SENTimelineMessage] && ![self.message isEqual:data[SENTimelineMessage]]) {
        self.message = data[SENTimelineMessage];
        changed = YES;
    }
    if (data[SENTimelineScore] && ![self.score isEqual:data[SENTimelineScore]]) {
        self.score = data[SENTimelineScore];
        changed = YES;
    }
    if (data[SENTimelineSegments]) {
        NSArray* segments = [self parseSegmentsFromArray:data[SENTimelineSegments]];
        if (![self.segments isEqual:segments]) {
            self.segments = segments;
            changed = YES;
        }
    }
    if (data[SENTimelineMetrics]) {
        NSArray* stats = [self parseMetricsFromArray:data[SENTimelineMetrics]];
        if (![self.metrics isEqual:stats]) {
            self.metrics = stats;
            changed = YES;
        }
    }
    if (data[SENTimelineScoreCondition]) {
        SENCondition condition = SENConditionFromString(data[SENTimelineScoreCondition]);
        if (self.scoreCondition != condition) {
            self.scoreCondition = condition;
            changed = YES;
        }
    }
    return changed;
}

- (NSString*)retrievalKey
{
    return [[self class] retrievalKeyForDate:self.date];
}

- (NSArray*)parseMetricsFromArray:(NSArray*)metricsData
{
    if (![metricsData isKindOfClass:[NSArray class]])
        return nil;
    __block NSMutableArray* metrics = [[NSMutableArray alloc] initWithCapacity:metricsData.count];
    for (NSDictionary* dict in metricsData) {
        if (![dict isKindOfClass:[NSDictionary class]])
            continue;
        SENTimelineMetric* metric = [[SENTimelineMetric alloc] initWithDictionary:dict];
        if (metric)
            [metrics addObject:metric];
    }
    return metrics;
}

- (NSArray *)parseSegmentsFromArray:(NSArray *)segmentsData {
    NSMutableArray *segments = [[NSMutableArray alloc] initWithCapacity:[segmentsData count]];
    SENTimelineSegment *previousSegment = nil;
    for (NSDictionary *segmentData in segmentsData) {
        SENTimelineSegment *segment = [[SENTimelineSegment alloc] initWithDictionary:segmentData];
        if ([previousSegment.message isEqual:segment.message]
            && previousSegment.type == segment.type
            && previousSegment.sleepDepth == segment.sleepDepth) {
            previousSegment.duration += segment.duration;
        } else if (segment != nil) {
            if (previousSegment)
                [segments addObject:previousSegment];
            previousSegment = segment;
        }
    }
    if (previousSegment)
        [segments addObject:previousSegment];
    return segments;
}

- (void)save
{
    [SENKeyedArchiver setObject:self forKey:[self retrievalKey] inCollection:NSStringFromClass([SENTimeline class])];
}

- (BOOL)isEqual:(SENTimeline*)object
{
    if (![object isKindOfClass:[SENTimeline class]])
        return NO;

    return ((self.date && [self.date isEqual:object.date]) || (!self.date && !object.date))
        && ((self.segments && [self.segments isEqualToArray:object.segments]) || (!self.segments && !object.segments))
        && ((self.metrics && [self.metrics isEqualToArray:object.metrics]) || (!self.metrics && !object.metrics))
        && ((self.score && [self.score isEqual:object.score]) || (!self.score && !object.score))
        && self.scoreCondition == object.scoreCondition
        && ((self.message && [self.message isEqual:object.message]) || (!self.message && !object.message));
}

- (NSUInteger)hash
{
    return [self.retrievalKey hash];
}

@end
