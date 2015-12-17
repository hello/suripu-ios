//
//  ModelCache.h
//  Sense
//
//  Created by Delisa Mason on 1/17/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

@import WatchKit;

@class SENTimeline, SENAlarm, SENSensor;

extern NSString *const ModelCacheUpdatedNotification;
extern NSString *const ModelCacheUpdatedObjectAlarms;
extern NSString *const ModelCacheUpdatedObjectSensors;
extern NSString *const ModelCacheUpdatedObjectSleepResult;

@interface ModelCache : NSObject

+ (NSArray<SENAlarm *> *)alarms;

+ (NSArray<SENSensor *> *)sensors;

+ (SENTimeline *)lastNightTimeline;

+ (void)refreshCache;

@end
