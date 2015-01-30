//
//  SENTrend.m
//  Pods
//
//  Created by Delisa Mason on 1/14/15.
//
//

#import "SENTrend.h"

@implementation SENTrend

static NSString* const SENTrendDataPointsKey = @"data_points";
static NSString* const SENTrendDataTypeKey = @"data_type";
static NSString* const SENTrendGraphTypeKey = @"graph_type";
static NSString* const SENTrendOptionsKey = @"options";
static NSString* const SENTrendTitleKey = @"title";
static NSString* const SENTrendTimePeriodKey = @"time_period";
static NSString* const SENTrendGraphTypeHistogramKey = @"HISTOGRAM";
static NSString* const SENTrendGraphTypeTimeSeriesLineKey = @"TIME_SERIES_LINE";

+ (SENTrendGraphType)graphTypeFromValue:(id)value
{
    if ([value isEqual:SENTrendGraphTypeHistogramKey])
        return SENTrendGraphTypeHistogram;
    else if ([value isEqual:SENTrendGraphTypeTimeSeriesLineKey])
        return SENTrendGraphTypeTimeSeriesLine;

    return SENTrendGraphTypeUnknown;
}

+ (NSArray*)optionsFromValue:(id)value
{
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray* options = value;
        NSMutableArray* validOptions = [[NSMutableArray alloc] initWithCapacity:options.count];
        for (id option in options) {
            if ([option isKindOfClass:[NSString class]])
                [validOptions addObject:option];
        }
        return validOptions;
    }
    return @[];
}

+ (NSArray*)dataPointsFromValue:(id)value
{
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray* points = value;
        NSMutableArray* validPoints = [[NSMutableArray alloc] initWithCapacity:points.count];
        for (id pointData in points) {
            if ([pointData isKindOfClass:[NSDictionary class]]) {
                SENTrendDataPoint* point = [[SENTrendDataPoint alloc] initWithDictionary:pointData];
                if (point)
                    [validPoints addObject:point];
            }
        }
        return validPoints;
    }
    return @[];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _dataPoints = [SENTrend dataPointsFromValue:dict[SENTrendDataPointsKey]];
        _dataType = dict[SENTrendDataTypeKey];
        _graphType = [SENTrend graphTypeFromValue:dict[SENTrendGraphTypeKey]];
        _options = [SENTrend optionsFromValue:dict[SENTrendOptionsKey]];
        _timePeriod = dict[SENTrendTimePeriodKey];
        _title = dict[SENTrendTitleKey];
    }
    return self;
}

@end

@implementation SENTrendDataPoint

static NSString* const SENTrendDataPointDateKey = @"datetime";
static NSString* const SENTrendDataPointYValueKey = @"y_value";
static NSString* const SENTrendDataPointXValueKey = @"x_value";
static NSString* const SENTrendDataPointOffsetMillisKey = @"offset_millis";
static NSString* const SENTrendDataPointQualityKey = @"data_label";
static NSString* const SENTrendDataPointQualityRawBad = @"BAD";
static NSString* const SENTrendDataPointQualityRawGood = @"GOOD";
static NSString* const SENTrendDataPointQualityRawOk = @"OK";

+ (NSDate*)dateForValue:(id)value
{
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber* timestamp = value;
        if ([timestamp doubleValue] <= 0)
            return nil;
        else
            return [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue] / 1000];
    }
    return nil;
}

+ (SENTrendDataPointQuality)qualityForValue:(id)value
{
    if ([value isEqual:SENTrendDataPointQualityRawBad])
        return SENTrendDataPointQualityBad;
    if ([value isEqual:SENTrendDataPointQualityRawGood])
        return SENTrendDataPointQualityGood;
    if ([value isEqual:SENTrendDataPointQualityRawOk])
        return SENTrendDataPointQualityOk;
    return SENTrendDataPointQualityUnknown;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _date = [SENTrendDataPoint dateForValue:dict[SENTrendDataPointDateKey]];
        _millisecondsOffset = [dict[SENTrendDataPointOffsetMillisKey] doubleValue];
        _quality = [SENTrendDataPoint qualityForValue:dict[SENTrendDataPointQualityKey]];
        _xValue = [dict[SENTrendDataPointXValueKey] doubleValue];
        _yValue = [dict[SENTrendDataPointYValueKey] doubleValue];
    }
    return self;
}

@end