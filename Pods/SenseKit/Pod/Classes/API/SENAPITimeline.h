
#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENTimelineSegment;

@interface SENAPITimeline : NSObject

/**
 *  GET /timeline/:day
 *
 *  Fetch the timeline data for a given date
 *
 *  @param completion block invoked when the network call is completed asynchronously
 */
+ (void)timelineForDate:(NSDate*)date completion:(SENAPIDataBlock)block;

/**
 * @method verifySleepEvent:completion
 *
 * @discussion
 * Mark the sleep event as correct, assuming the event allows such action.
 *
 * @param sleepEvent: the event to mark as correct / verify
 * @param date:       the date of sleep
 * @param block:      the block to excecute upon completion
 */
+ (void)verifySleepEvent:(SENTimelineSegment*)sleepEvent
          forDateOfSleep:(NSDate*)date
              completion:(SENAPIDataBlock)block;

/**
 * @method removeSleepEvent
 *
 * @discussion
 * Remove the specified event, assuming it's removable.
 *
 * @param sleepEvent: the event to mark remove
 * @param date:       the date of sleep
 * @param block:      the block to excecute upon completion
 */
+ (void)removeSleepEvent:(SENTimelineSegment*)sleepEvent
          forDateOfSleep:(NSDate*)date
              completion:(SENAPIDataBlock)block;

/**
 * @method amendSleepEvent:forDateOfSleep:withHour:andMinutes:completion
 *
 * @discussion
 * Amend the sleep event specified
 *
 * @param sleepEvent: the event to mark remove
 * @param date:       the date of sleep
 * @param hour:       the hour to change to
 * @param minutes:    the minutes to change to
 * @param completion: the block to excecute upon completion
 */
+ (void)amendSleepEvent:(SENTimelineSegment*)sleepEvent
         forDateOfSleep:(NSDate*)date
               withHour:(NSNumber*)hour
             andMinutes:(NSNumber*)minutes
             completion:(SENAPIDataBlock)block;

@end
