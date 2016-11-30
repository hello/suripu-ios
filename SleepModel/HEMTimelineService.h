//
//  HEMTimelineService.h
//  Sense
//
//  Created by Jimmy Lu on 1/14/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

@class SENAccount;
@class SENTimeline;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMTimelineNotificationTimelineAmended;

typedef void(^HEMTimelineServiceUpdateHandler)(SENTimeline* _Nullable updatedTimeline,
                                               NSError* _Nullable error);

@interface HEMTimelineService : SENService

/**
 * @discussion
 * Use this with care as it igores the date's actual day and only considers the
 * time of the date
 *
 * @return YES if the date is within the logic of determining if the date is still
 *         considered the previous day.
 */
- (BOOL)isWithinPreviousDayWindow:(NSDate*)date;

/**
 * @discussion
 * Determine whether an account may have timelines to view before the date specified.
 *
 * @param date: the date of sleep, usually
 * @param account: account to check
 * @return YES if the account may have more timelines to view that is older than
 *         the specified date.  If account is not specified, defaults to YES.
 */
- (BOOL)canViewTimelinesBefore:(NSDate*)date forAccount:(nullable SENAccount*)account;

/**
 * @discussion
 * Determine if the date is the first night of sleep for the specified account.
 * If the date of sleep is before the account's creation date, we will assume it
 * is the user's first night of sleep for the boundary case of the actual first
 * night of sleep, since night of sleep is usually -1 day of current day.
 *
 * @param date: the date of sleep
 * @param account: the account to check
 * @return YES if date is before or on the day of the account's creation date.
 *         NO otherwise.
 */
- (BOOL)isFirstNightOfSleep:(NSDate*)date forAccount:(nullable SENAccount*)account;

/**
 * @discussion
 * Update the timeline segment for the night of sleep with the new hour and minutes
 *
 * @param segment: the timeline segment to update / amend
 * @param date: the night of sleep the segment belongs to
 * @param hour: the new hour to change to
 * @param minutes: the new minutes to change to
 * @param completion: the block to call when the update is done
 */
- (void)amendTimelineSegment:(SENTimelineSegment*)segment
              forDateOfSleep:(NSDate*)date
                    withHour:(NSNumber*)hour
                  andMinutes:(NSNumber*)minutes
                  completion:(HEMTimelineServiceUpdateHandler)completion;

/**
 * @discussion
 * The string value for the date of the Timeline
 * 
 * @param date: the date for the timeline
 * @return the string value for the date, which depends on how many days ago
 */
- (NSString*)stringValueForTimelineDate:(NSDate*)date;

@end

NS_ASSUME_NONNULL_END
