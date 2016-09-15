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

static double const kHEMSensorDataRequestDelay = 10.0f;

@interface HEMSensorDataRequestOperation()

@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) SENSensorStatus* status;
@property (nonatomic, strong) SENSensorDataCollection* data;
@property (nonatomic, strong) NSError* error;
@property (nonatomic, strong) SENSensorDataRequest* dataRequest;

@end

@implementation HEMSensorDataRequestOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setQueuePriority:NSOperationQueuePriorityNormal];
        _repeatDelay = kHEMSensorDataRequestDelay;
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
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _completed = completed;
    _running = NO;
    if (completed && ![self isCancelled] && [self dataHandler]) {
        __weak typeof(self) weakSelf = self;
        [self notify:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf didChangeValueForKey:@"isFinished"];
            [strongSelf didChangeValueForKey:@"isExecuting"];
        }];
    } else {
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)setRunning:(BOOL)running {
    [self willChangeValueForKey:@"isExecuting"];
    _running = running;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)start {
    [self setRunning:YES];
    [self repeat];
}

- (void)notify:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf dataHandler]) {
            [strongSelf dataHandler] ([strongSelf dataScope],
                                      [strongSelf status],
                                      [strongSelf data],
                                      [strongSelf error]);
        }
        if (completion) {
            completion ();
        }
    });
}

- (void)repeat {
    if ([self isCancelled]) {
        [self setCompleted:YES];
        return;
    }
    
    [self setError:nil];
    [self setData:nil];
    [self setStatus:nil];
    
    __weak typeof(self) weakSelf = self;
    [SENAPISensor getSensorStatus:^(SENSensorStatus* status, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf isCancelled]) {
            [strongSelf setCompleted:YES];
        } else if (error) {
            [strongSelf setError:error];
            [strongSelf notify:nil];
        } else {
            [strongSelf setStatus:status];
            
            if (!status || [[status sensors] count] == 0) {
                [strongSelf notify:nil];
            } else {
                SENSensorDataRequest* request = [strongSelf dataRequest];
                if (!request) {
                    NSArray* filteredSensors = [strongSelf filter:[status sensors]];
                    request  = [SENSensorDataRequest new];
                    [request addRequestForSensors:filteredSensors
                                      usingMethod:[strongSelf dataMethod]
                                        withScope:[strongSelf dataScope]];
                    [strongSelf setDataRequest:request];
                }
                
                [SENAPISensor getSensorDataWithRequest:request completion:^(id data, NSError *error) {
                    [strongSelf setError:error];
                    [strongSelf setData:data];
                    [strongSelf notify:nil];

                    int64_t delayInSecs = (int64_t) ([strongSelf repeatDelay] * NSEC_PER_SEC);
                    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
                    dispatch_after(delay, dispatch_get_main_queue(), ^{
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf repeat];
                    });
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
