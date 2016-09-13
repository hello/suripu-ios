//
//  HEMRoomConditionPollOperation.m
//  Sense
//
//  Created by Jimmy Lu on 9/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENSensorStatus.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPISensor.h>
#import <SenseKit/SENSensorDataRequest.h>

#import "HEMSensorDataRequestOperation.h"

@interface HEMSensorDataRequestOperation()

@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) SENSensorStatus* status;
@property (nonatomic, strong) SENSensorDataCollection* data;
@property (nonatomic, strong) NSError* error;

@end

@implementation HEMSensorDataRequestOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setQueuePriority:NSOperationQueuePriorityNormal];
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return [self running];
}

- (BOOL)isFinished {
    return [self completed];
}

- (void)setCompleted:(BOOL)completed {
    [self willChangeValueForKey:@"isFinished"];
    _completed = completed;
    if (completed && [self dataHandler]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dataHandler] ([strongSelf status], [strongSelf data], [strongSelf error]);
            [strongSelf didChangeValueForKey:@"isFinished"];
        });
    } else {
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (void)setRunning:(BOOL)running {
    [self willChangeValueForKey:@"isExecuting"];
    _running = running;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)start {
    if ([self isCancelled]) {
        [self setCompleted:YES];
        return;
    }
    
    [self setRunning:YES];
    
    __weak typeof(self) weakSelf = self;
    
    [SENAPISensor getSensorStatus:^(SENSensorStatus* status, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf setError:error];
            [strongSelf setCompleted:YES];
        } else {
            [strongSelf setStatus:status];
            if (!status || [[status sensors] count] == 0) {
                [strongSelf setCompleted:YES];
            } else {
                NSArray* filteredSensors = [strongSelf filter:[status sensors]];
                SENSensorDataRequest* request  = [SENSensorDataRequest new];
                [request addRequestForSensors:filteredSensors
                                  usingMethod:[strongSelf dataMethod]
                                    withScope:[strongSelf dataScope]];
                
                [SENAPISensor getSensorDataWithRequest:request completion:^(id data, NSError *error) {
                    [strongSelf setError:error];
                    [strongSelf setData:data];
                    [strongSelf setCompleted:YES];
                }];
            }
        }
    }];
}

- (NSArray<SENSensor*>*)filter:(NSArray<SENSensor*>*)sensors {
    NSUInteger capacity = [sensors count] - [[self filterByTypes] count];
    NSMutableArray<SENSensor*>* filtered = [NSMutableArray arrayWithCapacity:capacity];
    for (SENSensor* sensor in sensors) {
        BOOL contains = [[self filterByTypes] containsObject:@([sensor type])];
        if (([self exclude] && !contains)
            || (![self exclude] && contains)) {
            [filtered addObject:sensor];
        }
    }
    return filtered;
}

@end
