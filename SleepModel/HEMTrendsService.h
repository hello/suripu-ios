//
//  HEMTrendsService.h
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENTrendsGraph.h>
#import <SenseKit/SENService.h>

@class SENTrends;
@class HEMTrendsDisplayPoint;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMTrendsServiceNotificationWillRefresh;
extern NSString* const HEMTrendsServiceNotificationDidRefresh;
extern NSString* const HEMTrendsServiceNotificationHitCache;
extern NSString* const HEMTrendsServiceNotificationInfoError;

typedef void(^HEMTrendsServiceDataHandler)(SENTrends* _Nullable trends, SENTrendsTimeScale scale, NSError* _Nullable error);

@interface HEMTrendsService : SENService

/**
 * @discussion
 *
 * YES if service is currently reloading trends cache from API. NO otherwise
 */
@property (nonatomic, assign, getter=isRefreshing, readonly) BOOL refreshing;

/**
 * @discussion
 *
 * Retrieve the trends for the selected time scale.  If cache has expired, or it
 * was never set, it does not exists, it will automatically grab the latest data 
 * from the API
 *
 * @param timeScale: the time scale for the trends to pull
 * @param completion: the block to call when data has been retrieved
 */
- (void)trendsFor:(SENTrendsTimeScale)timeScale completion:(nullable HEMTrendsServiceDataHandler)completion;

/**
 * @discussion
 *
 * Retrieve the trends for the selected time scale and override the cache if data
 * is returned.
 *
 * @param timeScale: the time scale for the trends to pull
 * @param completion: the block to call when data has been retrieved
 */
- (void)reloadTrends:(SENTrendsTimeScale)timeScale completion:(nullable HEMTrendsServiceDataHandler)completion;

/**
 * @discussion
 *
 * Check the cache to see if there are any trends that was previously pulled
 * available now.
 *
 * @param timeScale: the time scale for the trends
 * @return cached trends if any
 */
- (nullable SENTrends*)cachedTrendsForTimeScale:(SENTrendsTimeScale)timeScale;

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

/**
 * @discussion
 *
 * Number of days until more trends will appear.  More specifically, month and
 * quarter scales.
 *
 * @param currentTrends: trends currently used to display the data, if any
 * @return days until more trends
 */
- (NSInteger)daysUntilMoreTrends:(nullable SENTrends*)currentTrends;

/**
 * @return YES if data has been loaded at least once before
 */
- (BOOL)dataHasBeenLoaded;

/**
 * @return YES if current trends represents a data gap, aka user returned after
 *         several days of not using Sense and thus does not have enough data
 *         to render any graphs
 */
- (BOOL)isReturningUser:(nullable SENTrends*)currentTrends;

/**
 * @param trends: the trends to check if it's empty
 * @return YES if trends are empty / not available.  NO if there is something to
 *         display
 */
- (BOOL)isEmpty:(SENTrends*)trends;

/**
 * @discussion
 * Expire the current cache, if any
 */
- (void)expireCache;

@end

NS_ASSUME_NONNULL_END
