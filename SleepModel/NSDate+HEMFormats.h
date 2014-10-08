//
//  NSDate+HEMFormats.h
//  Sense
//
//  Created by Jimmy Lu on 10/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HEMFormats)

/**
 * Return a string format specifying the time that have passed from now.  The
 * format displays seconds ago up to weeks ago.  For ex:
 *
 *     1 second ago
 *    10 minutes ago
 *    11 hours ago
 *     5 days ago
 *    50 weeks ago
 *
 * @return the string format of time elapsed since now
 */
- (NSString*)timeAgo;

@end
