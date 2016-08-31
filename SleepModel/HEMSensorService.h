//
//  HEMSensorService.h
//  Sense
//
//  Created by Jimmy Lu on 3/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

@class SENSensor;

@interface HEMSensorService : SENService

/**
 * @return a sorted array of cached SENSensor objects.  The sort order is the
 *         preferred order of the sensors, if displayed in a list
 */
- (NSArray<SENSensor*>*)sortedCacheSensors;

@end
