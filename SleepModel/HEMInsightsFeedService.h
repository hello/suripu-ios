//
//  HEMInsightsFeedService.h
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

@class SENInsight;

typedef void(^HEMInsightsFeedInsightHandler)(NSArray<SENInsight*>* _Nullable insights,
                                             NSError* _Nullable error);

@interface HEMInsightsFeedService : SENService

@property (nonatomic, strong, readonly, nullable) NSArray<SENInsight*>* insights;

- (void)refreshInsights:(nonnull HEMInsightsFeedInsightHandler)completion;

@end
