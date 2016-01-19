//
//  HEMTimelineService.h
//  Sense
//
//  Created by Jimmy Lu on 1/14/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

@class SENAccount;

NS_ASSUME_NONNULL_BEGIN

@interface HEMTimelineService : SENService

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

@end

NS_ASSUME_NONNULL_END