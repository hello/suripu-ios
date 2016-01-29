//
//  HEMTrendsService.h
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENTrendsGraph.h>
#import "SENService.h"

@class SENTrends;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMTrendsServiceDataHandler)(SENTrends* _Nullable trends, SENTrendsTimeScale scale, NSError* _Nullable error);

@interface HEMTrendsService : SENService

- (void)refreshTrendsFor:(SENTrendsTimeScale)timeScale completion:(HEMTrendsServiceDataHandler)completion;
- (SENTrends*)cachedTrendsForTimeScale:(SENTrendsTimeScale)timeScale;

@end

NS_ASSUME_NONNULL_END