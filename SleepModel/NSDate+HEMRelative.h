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

- (NSDate*)nextDay;

- (NSDate*)previousDay;

- (BOOL)isOnSameDay:(NSDate *)otherDate;

@end
