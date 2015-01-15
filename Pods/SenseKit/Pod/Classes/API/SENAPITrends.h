//
//  SENAPITrends.h
//  Pods
//
//  Created by Delisa Mason on 1/14/15.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENTrend;

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

@end
