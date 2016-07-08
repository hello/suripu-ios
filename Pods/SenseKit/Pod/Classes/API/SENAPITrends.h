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