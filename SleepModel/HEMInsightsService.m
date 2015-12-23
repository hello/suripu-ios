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

static NSString* const HEMInsightsServiceCategoryGeneric = @"GENERIC";
static NSString* const HEMInsightsServiceCategorySleepDuration = @"SLEEP_DURATION";
static NSString* const HEMInsightsServiceCategorySleepHygiene = @"SLEEP_HYGIENE";

@implementation HEMInsightsService

- (void)getListOfInsightSummaries:(nonnull HEMInsightSummariesHandler)completion {
    [SENAPIInsight getInsights:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (void)getInsightForSummary:(SENInsight*)insight completion:(HEMInsightHandler)completion {
    [SENAPIInsight getInfoForInsight:insight completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (BOOL)isGenericInsight:(SENInsight*)insight {
    NSString* category = [[insight category] uppercaseString];
    return [category isEqualToString:HEMInsightsServiceCategoryGeneric]
        || [category isEqualToString:HEMInsightsServiceCategorySleepDuration]
        || [category isEqualToString:HEMInsightsServiceCategorySleepHygiene];
}

@end
