//
//  NSTimeZone+HEMMapping.h
//  Sense
//
//  Created by Jimmy Lu on 7/10/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimeZone (HEMMapping)

/**
 * @method localTimeZoneMappedName
 *
 * @discussion:
 * Convenience method to extract the mapping name for the local time zone, falling
 * back to the time zone name if none found.  This is used for display purposes
 *
 * @return mapped name for the local time zone.  e.g Pacific Time (US & Canada)
 */
+ (NSString*)localTimeZoneMappedName;

/**
 * @method timeZoneMapping
 *
 * @return the known mappings that are widely used
 */
+ (NSDictionary*)timeZoneMapping;

@end
