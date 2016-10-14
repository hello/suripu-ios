
#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENAlarmCollection;

NS_ASSUME_NONNULL_BEGIN

@interface SENAPIAlarms : NSObject

/**
 *  Fetch stored alarms
 *
 *  @param completion block invoked when call completes asynchronously,
 *                    with the data parameter set to returned alarm data
 */
+ (void)alarmsWithCompletion:(SENAPIDataBlock)completion;

/**
 *  Update stored alarms
 *
 *  @param alarms     an collection of alarms
 *  @param completion block invoked when call completes asynchronously
 *                    with the data parameter set to returned alarm data
 */
+ (void)updateAlarms:(SENAlarmCollection*)alarms completion:(nullable SENAPIDataBlock)completion;

/**
 *  Fetch available sounds for alarms
 *
 *  @param completion block invoked when call completes asynchronously
 *                    with the data parameter set to sounds data
 */
+ (void)availableSoundsWithCompletion:(SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END