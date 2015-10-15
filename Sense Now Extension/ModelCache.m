//
//  ModelCache.m
//  Sense
//
//  Created by Delisa Mason on 1/17/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SenseKit.h>
#import "ModelCache.h"

NSString *const ModelCacheUpdatedNotification = @"ModelCacheUpdatedNotification";
NSString *const ModelCacheUpdatedObjectAlarms = @"alarms";
NSString *const ModelCacheUpdatedObjectSensors = @"sensors";
NSString *const ModelCacheUpdatedObjectSleepResult = @"sleepResult";

@implementation ModelCache

static NSArray *cachedAlarms = nil;
static NSArray *cachedSensors = nil;
static SENTimeline *timeline = nil;

static NSString *const HEMAPIProdPath = @"https://api.hello.is";
static NSString *const HEMAPIDevPath = @"https://dev-api.hello.is";

+ (NSArray *)alarms {
    return cachedAlarms;
}

+ (NSArray *)sensors {
    return cachedSensors;
}

+ (SENTimeline *)lastNightTimeline {
    return timeline;
}

+ (void)refreshCache {
    [self configureAPI];
    [self refreshTimeline];
    [self refreshAlarms];
    [self refreshSensors];
}

+ (NSDate *)yesterday {
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* components = [NSDateComponents new];
    components.day = -1;
    return [calendar dateByAddingComponents:components
                                     toDate:[NSDate date]
                                    options:0];
}

+ (void)refreshTimeline {
    NSDate *yesterday = [self yesterday];
    timeline = timeline ?: [SENTimeline timelineForDate:yesterday];
    [SENAPITimeline timelineForDate:yesterday
                         completion:^(NSArray *timelines, NSError *error) {
                           if (error || timelines.count == 0)
                               return;
                           timeline = [[SENTimeline alloc] initWithDictionary:[timelines firstObject]];
                           [timeline save];
                           [[NSNotificationCenter defaultCenter]
                               postNotificationName:ModelCacheUpdatedNotification
                                             object:ModelCacheUpdatedObjectSleepResult];
                         }];
}

+ (void)refreshAlarms {
    [SENAPIAlarms alarmsWithCompletion:^(NSArray *alarms, NSError *error) {
      if (error)
          return;
      cachedAlarms = alarms;
      [[NSNotificationCenter defaultCenter] postNotificationName:ModelCacheUpdatedNotification
                                                          object:ModelCacheUpdatedObjectAlarms];
    }];
}

+ (void)refreshSensors {
    [SENAPIRoom currentWithCompletion:^(NSDictionary *data, NSError *error) {
      if (error)
          return;
      NSMutableArray *sensors = [[NSMutableArray alloc] initWithCapacity:data.count];
      for (NSString *key in data) {
          NSMutableDictionary *sensorData = [data[key] mutableCopy];
          sensorData[@"name"] = key;
          SENSensor *sensor = [[SENSensor alloc] initWithDictionary:sensorData];
          if (sensor)
              [sensors addObject:sensor];
      }
      cachedSensors = sensors;
      [[NSNotificationCenter defaultCenter] postNotificationName:ModelCacheUpdatedNotification
                                                          object:ModelCacheUpdatedObjectSensors];
    }];
}

+ (void)configureAPI {
    NSString *path = nil;
#if DEBUG
    path = HEMAPIDevPath;
#else
    path = HEMAPIProdPath;
#endif
    [SENAPIClient setBaseURLFromPath:path];
    [SENAuthorizationService authorizeRequestsFromKeychain];
}

@end
