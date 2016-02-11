//
//  SENAPITrends.h
//  Pods
//
//  Created by Delisa Mason on 1/14/15.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"
#import "SENTrendsGraph.h"

@class SENTrend;

NS_ASSUME_NONNULL_BEGIN

@interface SENAPITrends : NSObject

/**
 *  GET insights/trends/all
 *
 *  @param completion block invoked when request completes asynchronously
 */
+ (void)defaultTrendsListWithCompletion:(SENAPIDataBlock)completion;

/**
 *  GET insights/trends/list
 *
 *  @param completion block invoked when request completes asynchronously
 */
+ (void)allTrendsListWithCompletion:(SENAPIDataBlock)completion;

/**
 *  GET insights/trends/graph?data_type=sleep_score&time_period=:period
 *
 *  @param timePeriod the period type string representing a time period
 *  @param completion block invoked when request completes asynchronously
 */
+ (void)sleepScoreTrendForTimePeriod:(NSString*)timePeriod
                          completion:(SENAPIDataBlock)completion;

/**
 *  GET insights/trends/graph?data_type=sleep_duration&time_period=:period
 *
 *  @param timePeriod the period type string representing a time period
 *  @param completion block invoked when request completes asynchronously
 */
+ (void)sleepDurationTrendForTimePeriod:(NSString*)timePeriod
                             completion:(SENAPIDataBlock)completion;

/**
 * @discussion
 *
 * Get trends from the v2 API
 *
 * @param timeScale: the time scale to retrieve trends for
 * @param completion: the block to call when request is completed
 */
+ (void)trendsForTimeScale:(SENTrendsTimeScale)timeScale
                completion:(SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END