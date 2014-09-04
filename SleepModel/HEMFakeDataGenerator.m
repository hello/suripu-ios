
#import "HEMFakeDataGenerator.h"

@implementation HEMFakeDataGenerator

+ (NSDictionary*)sleepDataForDate:(NSDate*)date
{
    if (arc4random() % 4 == 1) {
        return nil;
    }

    NSMutableArray* slices = [[NSMutableArray alloc] initWithCapacity:40];
    CGFloat startTimeMillis = (([[NSDate date] timeIntervalSince1970] - 10 * 60 * 60) * 1000);
    CGFloat totalDuration = 0;
    NSMutableDictionary* dict = [[self createSliceWithID:0 timestamp:startTimeMillis] mutableCopy];
    dict[@"type"] = @"sleep";
    dict[@"message"] = @"You fell asleep a little late today";
    dict[@"duration"] = @0;
    [slices addObject:dict];
    for (int i = 0; i < 30; i++) {
        CGFloat timestamp = startTimeMillis + totalDuration;
        CGFloat duration = (arc4random() % 20) * 100000;
        [slices addObject:[self createSliceWithID:i + 1 timestamp:timestamp]];
        totalDuration += duration;
    }
    dict = [[self createSliceWithID:32 timestamp:(startTimeMillis + totalDuration)] mutableCopy];
    dict[@"type"] = @"awake";
    dict[@"message"] = @"You woke up!";
    dict[@"duration"] = @0;
    [slices addObject:dict];
    NSString* message = @[
        @"You slept for an hour more than usual",
        @"You were in bed for 9 hours and asleep for 7.5 hours",
        @"You went to bed a bit late and your sleep quality suffered as a result",
        @"It was a bit warmer than usual",
        @"Maybe cut down on the Netflix binges?",
    ][arc4random() % 5];
    return @{
        @"date" : @([date timeIntervalSince1970] * 1000),
        @"offset_millis" : @0,
        @"score" : @(arc4random() % 95),
        @"message" : message,
        @"segments" : [[slices reverseObjectEnumerator] allObjects]
    };
}

+ (NSDictionary*)createSliceWithID:(NSUInteger)identifier timestamp:(NSTimeInterval)timestamp
{
    CGFloat duration = (arc4random() % 20) * 100000;
    NSString* message = [NSString stringWithFormat:@"Something unexplainable occurred for %.f minutes.", duration / 1000 / 60];
    NSString* type = @"none";
    if (arc4random() % 9 == 8) {
        type = @[ @"light", @"noise", @"none" ][arc4random() % 3];
    }
    return @{
        @"id" : @(identifier),
        @"date" : @(timestamp),
        @"offset_millis" : @0,
        @"duration" : @(duration),
        @"sleep_depth" : @(floorf(arc4random() % 3) + 1),
        @"event_type" : type,
        @"message" : message,
        @"sensors" : [self randomSensorData]
    };
}

+ (NSDictionary*)randomSensorData
{
    return @{
        @"temperature" : @{
            @"value" : @(arc4random() % 33),
            @"unit" : @"c"
        },
        @"humidity" : @{
            @"value" : @(arc4random() % 100),
            @"unit" : @"%"
        },
        @"particulates" : @{
            @"value" : @(arc4random() % 700),
            @"unit" : @"ppm"
        },
    };
}

+ (NSArray*)summarySleepScoresFromDate:(NSDate*)date
{
    NSMutableArray* scores = [[NSMutableArray alloc] initWithCapacity:7];
    NSTimeInterval startInterval = [date timeIntervalSince1970];
    for (int i = 0; i < 8; i++) {
        NSTimeInterval interval = startInterval - (i * 60 * 60 * 24);
        [scores addObject:@{
            @"score" : @(arc4random() % 95),
            @"date" : @(interval * 1000),
            @"offset_millis" : @0
        }];
    }
    return scores;
}

@end
