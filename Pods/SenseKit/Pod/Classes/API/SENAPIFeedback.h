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
 *  Updates the recorded time for selected events to a reported hour and minute
 *
 *  @param eventType  type of event to be updated, such as IN_BED, WOKE_UP
 *  @param hour       hour the event actually occurred
 *  @param minute     minute the event actually occurred
 *  @param sleepDate  date for night of sleep
 *  @param completion block invoked when asynchronous call completes
 */
+ (void)updateEvent:(NSString*)eventType
           withHour:(NSUInteger)hour
             minute:(NSUInteger)minute
    forNightOfSleep:(NSDate*)sleepDate
         completion:(SENAPIErrorBlock)completion;
@end
