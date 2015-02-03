//
//  HEMTutorial.h
//  Sense
//
//  Created by Delisa Mason on 1/28/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMTutorial : NSObject

/**
 *  Present the timeline tutorial if not previously viewed
 */
+ (void)showTutorialForTimelineIfNeeded;

+ (void)showTutorialForTimeline;

/**
 *  Present the tutorial for the sensor overview screen if not previously viewed
 */
+ (void)showTutorialForSensorsIfNeeded;

+ (void)showTutorialForSensors;

/**
 *  Present the tutorial for a particular sensor if not previously viewed
 *
 *  @param sensorName name of the sensor
 */
+ (void)showTutorialIfNeededForSensorNamed:(NSString*)sensorName;

+ (void)showTutorialForSensorNamed:(NSString*)sensorName;


@end
