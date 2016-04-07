//
//  HEMSleepSoundStatusCheckOperation.m
//  Sense
//
//  Created by Jimmy Lu on 4/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSleepSoundStatus.h>
#import <SenseKit/SENAPISleepSounds.h>

#import "HEMSleepSoundStatusCheckOperation.h"

@interface HEMSleepSoundStatusCheckOperation()

@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) SENSleepSoundStatus* status;

@end

@implementation HEMSleepSoundStatusCheckOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setQueuePriority:NSOperationQueuePriorityLow];
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
    if (completed && [self resultCompletionBlock]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf resultCompletionBlock] ([strongSelf status]);
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
    
    __weak typeof(self) weakSelf = self; // probably won't need it, but just in case
    [SENAPISleepSounds checkRequestStatus:^(id data, NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setStatus:data];
        [strongSelf setCompleted:YES];
    }];
}

@end
