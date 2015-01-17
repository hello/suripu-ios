//
//  SENAPIInsight.m
//  Pods
//
//  Created by Jimmy Lu on 10/28/14.
//
//

#import "SENAPIInsight.h"
#import "SENInsight.h"

static NSString* const kSENAPIInsightPath = @"insights";
static NSString* const kSENAPIInsightErrorDomain = @"is.hello.api.insight";

@implementation SENAPIInsight

+ (NSArray*)insightsFromResponse:(id)response {
    if (![response isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray* insights = [NSMutableArray arrayWithCapacity:[response count]];
    for (id object in response) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [insights addObject:[[SENInsight alloc] initWithDictionary:object]];
        }
    }
    
    return insights;
}

+ (SENInsightInfo*)insightInfoFromResponse:(id)response {
    SENInsightInfo* info = nil;
    // as of Jan 16, 2015, insight info will return an array of possibly greater
    // than 1 info object, but we don't forsee this to be needed anytime soon or
    // ever so we will hide the fact that an array is returned and simply return
    // the first instance so we don't have to change this logic elsewhere, potentially
    // in multiple places
    if ([response isKindOfClass:[NSArray class]] && [response count] > 0) {
        id infoObj = [response firstObject];
        if ([infoObj isKindOfClass:[NSDictionary class]]) {
            info = [[SENInsightInfo alloc] initWithDictionary:infoObj];
        }
    }
    return info;
}

+ (void)getInsights:(SENAPIDataBlock)completion {
    if (!completion) return; // why do work for nothing?
    
    [SENAPIClient GET:kSENAPIInsightPath parameters:nil completion:^(id data, NSError *error) {
        NSArray* insights = error == nil ? [self insightsFromResponse:data] : nil;
        completion (insights, error);
    }];
}

+ (void)getInfoForInsight:(SENInsight*)insight completion:(SENAPIDataBlock)completion {
    if (!completion) return;
    if ([[insight category] length] == 0) {
        completion (nil, [NSError errorWithDomain:kSENAPIInsightErrorDomain
                                             code:SENAPIInsightErrorInvalidArgument
                                         userInfo:nil]);
        return;
    }
    
    NSString* path = [NSString stringWithFormat:@"%@/info/%@", kSENAPIInsightPath, [insight category]];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        completion ([self insightInfoFromResponse:data], error);
    }];
}

@end
