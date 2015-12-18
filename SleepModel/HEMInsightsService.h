//
//  HEMInsightsService.h
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

@class SENInsight;
@class SENInsightInfo;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMInsightSummariesHandler)(NSArray<SENInsight*>* _Nullable insights,
                                          NSError* _Nullable error);

typedef void(^HEMInsightHandler)(SENInsightInfo* _Nullable insight, NSError* _Nullable error);

@interface HEMInsightsService : SENService

/**
 * @discussion
 * Retrieve a list of insight summaries
 */
- (void)getListOfInsightSummaries:(HEMInsightSummariesHandler)completion;

/**
 * @discussion
 * Retrieve the insight
 */
- (void)getInsightForSummary:(SENInsight*)insight completion:(HEMInsightHandler)completion;

/**
 * @param insight: the insight to check if it's a generic insight that is not
 *                 personalized to the user
 * @retutn YES if it's generic, NO otherwise
 */
- (BOOL)isGenericInsight:(SENInsight*)insight;

@end

NS_ASSUME_NONNULL_END
