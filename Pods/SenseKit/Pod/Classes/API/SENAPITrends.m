//
//  SENAPITrends.m
//  Pods
//
//  Created by Delisa Mason on 1/14/15.
//
//

#import "SENAPITrends.h"
#import "SENTrend.h"
#import "SENTrends.h"

@implementation SENAPITrends

static NSString* const SENAPITrendsDefaultEndpoint = @"v1/insights/trends/all";
static NSString* const SENAPITrendsAllEndpoint = @"v1/insights/trends/list";
static NSString* const SENAPITrendsGraphEndpoint = @"v1/insights/trends/graph";
static NSString* const SENAPITrendsTimePeriod = @"time_period";
static NSString* const SENAPITrendsDataType = @"data_type";
static NSString* const SENAPITrendsSleepScoreType = @"sleep_score";
static NSString* const SENAPITrendsSleepDurationType = @"sleep_duration";

static NSString* const SENAPITrendsEndpoint = @"v2/trends";

+ (void)defaultTrendsListWithCompletion:(SENAPIDataBlock)completion
{
    [self fetchEndpoint:SENAPITrendsDefaultEndpoint parameters:nil completion:completion];
}

+ (void)allTrendsListWithCompletion:(SENAPIDataBlock)completion
{
    [self fetchEndpoint:SENAPITrendsAllEndpoint parameters:nil completion:completion];
}

+ (void)sleepScoreTrendForTimePeriod:(NSString *)timePeriod
                          completion:(SENAPIDataBlock)completion
{
    NSDictionary* params = @{SENAPITrendsTimePeriod: timePeriod ?: @"",
                             SENAPITrendsDataType : SENAPITrendsSleepScoreType};
    [self fetchEndpoint:SENAPITrendsGraphEndpoint parameters:params completion:completion];
}

+ (void)sleepDurationTrendForTimePeriod:(NSString *)timePeriod
                             completion:(SENAPIDataBlock)completion
{
    NSDictionary* params = @{SENAPITrendsTimePeriod: timePeriod ?: @"",
                             SENAPITrendsDataType : SENAPITrendsSleepDurationType};
    [self fetchEndpoint:SENAPITrendsGraphEndpoint parameters:params completion:completion];
}

+ (void)fetchEndpoint:(NSString*)endpoint parameters:(NSDictionary*)params completion:(SENAPIDataBlock)completion
{
    if (!completion)
        return;
    [SENAPIClient GET:endpoint parameters:params completion:^(NSArray* data, NSError *error) {
        completion(data ? [SENAPITrends trendsFromDataArray:data] : nil, error);
    }];
}

+ (NSArray*)trendsFromDataArray:(NSArray*)data
{
    NSMutableArray* trends = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (NSDictionary* dict in data) {
        SENTrend* trend = [[SENTrend alloc] initWithDictionary:dict];
        if (trend)
            [trends addObject:trend];
    }
    return trends;
}

+ (void)trendsForTimeScale:(SENTrendsTimeScale)timeScale completion:(SENAPIDataBlock)completion {
    NSString* scalePath = SENTrendsTimeScaleValueFromEnum(timeScale);
    NSString* endpoint = [SENAPITrendsEndpoint stringByAppendingPathComponent:scalePath];
    [SENAPIClient GET:endpoint parameters:nil completion:^(id data, NSError *error) {
        SENTrends* trends = nil;
        if ([data isKindOfClass:[NSDictionary class]] && !error) {
            trends = [[SENTrends alloc] initWithDictionary:data];
        }
        completion (trends, error);
    }];
}

@end
