//
//  HEMInsightsService.h
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

@class SENInsight;

typedef void(^HEMInsightSummariesHandler)(NSArray<SENInsight*>* _Nullable insights,
                                          NSError* _Nullable error);

@interface HEMInsightsService : SENService

/**
 * @discussion
 * Refresh insights
 */
- (void)getListOfInsightSummaries:(nonnull HEMInsightSummariesHandler)completion;

@end
