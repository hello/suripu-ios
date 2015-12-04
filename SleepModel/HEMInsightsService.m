//
//  HEMInsightsService.m
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENAPIInsight.h>
#import <SenseKit/SENInsight.h>
#import <SenseKit/SENAppUnreadStats.h>

#import "HEMInsightsService.h"

@implementation HEMInsightsService

- (void)getListOfInsightSummaries:(nonnull HEMInsightSummariesHandler)completion {
    [SENAPIInsight getInsights:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

@end
