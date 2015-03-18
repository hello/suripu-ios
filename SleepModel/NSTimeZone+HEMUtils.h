//
//  NSTimeZone+HEMUtils.h
//  Sense
//
//  Created by Jimmy Lu on 3/17/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimeZone (HEMUtils)

/**
 * @method senseUnsupportedTimeZoneIds
 *
 * @discussion
 * There are a set of time zone ids that the server does not recognize, but
 * are known to iOS.  It's recommended that we simply filter these out.
 *
 * @return a set of unsupported time zone ids
 */
+ (NSSet*)senseUnsupportedTimeZoneIds;

/**
 * @method supportedTimeZoneByDisplayNames
 *
 * @return a dictionary where the key is the localized display name of the time
 *         zone and the value is the decided NSTimeZone object associated to it.
 */
+ (NSDictionary*)supportedTimeZoneByDisplayNames;

@end
