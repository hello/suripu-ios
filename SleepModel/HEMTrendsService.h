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
@class HEMTrendsDisplayPoint;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMTrendsServiceDataHandler)(SENTrends* _Nullable trends, SENTrendsTimeScale scale, NSError* _Nullable error);

@interface HEMTrendsService : SENService

/**
 * @discussion
 *
 * Refreshing the trends is guarded with a cache check to prevent too many requests
 * being fired uncessarily.  If cache has expired, or it was never set, it does not
 * exists, it will automatically grab the latest data from the API
 *
 * @param timeScale: the time scale for the trends to pull
 * @param completion: the block to call when data has been retrieved
 */
- (void)refreshTrendsFor:(SENTrendsTimeScale)timeScale completion:(HEMTrendsServiceDataHandler)completion;

/**
 * @discussion
 *
 * Check the cache to see if there are any trends that was previously pulled
 * available now.
 *
 * @param timeScale: the time scale for the trends
 * @return cached trends if any
 */
- (SENTrends*)cachedTrendsForTimeScale:(SENTrendsTimeScale)timeScale;

/**
 * @discussion
 * 
 * Convenience method to determine / extract the light, medium, and deep sleep
 * percentages from the trends graph data, if applicable
 *
 * @param lightPercentage: a pointer to the address to hold the light sleep value
 * @param mediumPercentage: a pointer to the address to hold the medium sleep value
 * @param deepPercentage: a pointer to the address to hold the deep sleep value
 * @param graph: the graph data
 */
- (void)sleepDepthLightPercentage:(CGFloat*)lightPercentage
                 mediumPercentage:(CGFloat*)mediumPercentage
                   deepPercentage:(CGFloat*)deepPercentage
                         forGraph:(SENTrendsGraph*)graph;

/**
 * @discussion
 *
 * Convenience method to translate graph data to display data points.
 *
 * @param graph: the graph data
 * @return segmented display points
 */
- (NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)segmentedDataPointsFrom:(SENTrendsGraph*)graph;

/**
 * @discussion
 *
 * Reference the graph's condition ranges to determine the condition of the
 * specified value
 *
 * @param value: the value to check
 * @return graph that is displaying the value
 */
- (SENCondition)conditionForValue:(NSNumber*)value inGraph:(SENTrendsGraph*)graph;

@end

NS_ASSUME_NONNULL_END