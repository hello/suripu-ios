//
//  NSDate+HEMRelative.h
//  Sense
//
//  Created by Jimmy Lu on 12/17/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HEMRelative)

/**
 *  Date to display while initializing a timeline view
 *
 *  @return a date
 */
+ (NSDate*)timelineInitialDate;

/**
 *  @return a date with year, month and day
 */
+ (NSDate*)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

/**
 * @return number of days that from today
 */
- (NSInteger)daysElapsed;

/**
 * @return NSString representation of the time that have elapsed since now 
 *         in the form:
 *              Today
 *              5d
 *              46w
 *              88y
 */
- (NSString*)elapsed;

/**
 * @return NSString representation of the time that has passed ago in the
 *         format of:
 *              now
 *              3 seconds ago
 *              5 minutes ago
 *              6 hours ago
 *              ...
 *              7 years ago
 */
- (NSString*)timeAgo;

- (NSDate*)dateAtMidnight;

- (NSDate*)daysFromNow:(NSInteger)days;

- (NSDate*)nextDay;

- (NSDate*)previousDay;

- (NSInteger)dayOfWeek;

- (BOOL)isOnSameDay:(NSDate *)otherDate;

- (NSDate*)previousMonth;

- (NSDate*)nextMonth;

- (BOOL)isCurrentMonth;

- (NSUInteger)hoursElapsed;

- (NSDate*)monthsFromNow:(NSInteger)months;

/**
 *  Checks if the current time is the early morning hours of 'today'
 *
 *  @discussion If a user checks their timeline/history during the early
 *  hours while still in bed, they should see the data from the previous
 *  day instead of "Not Enough Data", as they are still in bed.
 *
 *  @return YES if it is early in the morning of 'today'
 */
- (BOOL)shouldCountAsPreviousDay;
@end
