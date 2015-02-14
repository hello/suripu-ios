//
//  SENAPIFeedback.h
//  Pods
//
//  Created by Delisa Mason on 12/4/14.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENSleepResultSegment;

@interface SENAPIFeedback : NSObject

/**
 *  Updates the recorded time for selected events to a reported hour and minute
 *
 *  @param segment    type of segment to be updated
 *  @param hour       hour the event actually occurred
 *  @param minute     minute the event actually occurred
 *  @param detected   date at which the event was detected to occur
 *  @param sleepDate  date for night of sleep
 *  @param completion block invoked when asynchronous call completes
 */
+ (void)updateSegment:(SENSleepResultSegment*)segment
             withHour:(NSUInteger)hour
               minute:(NSUInteger)minute
      forNightOfSleep:(NSDate*)sleepDate
           completion:(SENAPIErrorBlock)completion;
@end
