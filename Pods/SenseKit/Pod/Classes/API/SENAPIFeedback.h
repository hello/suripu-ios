//
//  SENAPIFeedback.h
//  Pods
//
//  Created by Delisa Mason on 12/4/14.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@interface SENAPIFeedback : NSObject

/**
 *  Reports an inaccurate wake-up time with a correction
 *
 *  @param wakeupTime   reported wake-up time or nil detected time is correct
 *  @param detectedTime detected wake-up time, if available
 *  @param sleepDate    date for night of sleep
 *  @param block        completion block invoked when call completes
 */
+ (void)sendAccurateWakeupTime:(NSDate *)wakeupTime
            detectedWakeupTime:(NSDate *)detectedTime
               forNightOfSleep:(NSDate *)sleepDate
                    completion:(SENAPIErrorBlock)block;

@end
