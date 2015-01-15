//
//  SENAPITrends.m
//  Pods
//
//  Created by Delisa Mason on 1/14/15.
//
//

#import "SENAPITrends.h"
#import "SENTrend.h"

@implementation SENAPITrends

static NSString* const SENAPITrendsDefaultEndpoint = @"insights/trends/all";
static NSString* const SENAPITrendsAllEndpoint = @"insights/trends/list";
static NSString* const SENAPITrendsGraphEndpoint = @"insights/trends/graph";
static NSString* const SENAPITrendsTimePeriod = @"time_period";
static NSString* const SENAPITrendsDataType = @"data_type";
static NSString* const SENAPITrendsSleepScoreType = @"sleep_score";
static NSString* const SENAPITrendsSleepDurationType = @"sleep_duration";


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

@end
