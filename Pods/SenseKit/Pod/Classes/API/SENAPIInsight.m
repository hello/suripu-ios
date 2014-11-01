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

+ (void)getInsights:(SENAPIDataBlock)completion {
    if (!completion) return; // why do work for nothing?
    
    [SENAPIClient GET:kSENAPIInsightPath parameters:nil completion:^(id data, NSError *error) {
        NSArray* insights = error == nil ? [self insightsFromResponse:data] : nil;
        completion (insights, error);
    }];
}

@end
