//
//  SENAPITrends.m
//  Pods
//
//  Created by Delisa Mason on 1/14/15.
//
//

#import "SENAPITrends.h"
#import "SENTrends.h"

@implementation SENAPITrends

static NSString* const SENAPITrendsEndpoint = @"v2/trends";

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
