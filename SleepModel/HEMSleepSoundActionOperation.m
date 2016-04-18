//
//  HEMSleepSoundActionOperation.m
//  Sense
//
//  Created by Jimmy Lu on 4/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAPISleepSounds.h>
#import <SenseKit/SENSleepSoundStatus.h>
#import <SenseKit/SENSleepSoundRequest.h>

#import "HEMSleepSoundActionOperation.h"

NSString* const HEMSleepSoundActionErrorDomain = @"is.hello.app.sleep-sound.action.operation";
static CGFloat const HEMSleepSoundActionStatusTimeout = 30.0f;
static CGFloat const HEMSleepSoundActionStatusCheckDelay = 0.2f;
static CGFloat const HEMSleepSoundActionRequestBackoff = 2.0f;

@interface HEMSleepSoundActionOperation()

@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) SENSleepSoundRequest* action;
@property (nonatomic, strong) NSError* actionError;
@property (nonatomic, strong) NSTimer* statusCheckTimer;

@end

@implementation HEMSleepSoundActionOperation

- (instancetype)initWithAction:(SENSleepSoundRequest*)action {
    self = [super init];
    if (self) {
        _action = action;
        [self setQueuePriority:NSOperationQueuePriorityVeryHigh];
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
            [strongSelf resultCompletionBlock] ([strongSelf isCancelled],
                                                [strongSelf actionError]);
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
    [SENAPISleepSounds executeRequest:[self action] completion:^(NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf failWithError:error];
        } else {
            [strongSelf checkStatus:0];
        }
    }];
}

#pragma mark - Action Status

- (CGFloat)nextStatusCheckDelay:(NSInteger)attempts {
    // exponential backoff
    return pow(HEMSleepSoundActionRequestBackoff, attempts) * HEMSleepSoundActionStatusCheckDelay;
}

- (void)checkStatus:(NSInteger)attempt {
    if ([self isCancelled]) {
        [[self statusCheckTimer] invalidate];
        [self setStatusCheckTimer:nil];
        [self setCompleted:YES];
        return;
    }
    
    if (attempt == 0) {
        [self scheduleStatusTimer];
    } else if (![[self statusCheckTimer] isValid]) { // timedout already
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPISleepSounds checkRequestStatus:^(SENSleepSoundStatus* status, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf failWithError:error];
        } else if (![strongSelf isExpectedStatus:status]){
            [strongSelf checkStatusAgainWithAttempt:attempt + 1];
        } else { // must be successful
            [[strongSelf statusCheckTimer] invalidate];
            [strongSelf setStatusCheckTimer:nil];
            [strongSelf setRunning:NO];
            [strongSelf setCompleted:YES];
        }
    }];
}

- (void)checkStatusAgainWithAttempt:(NSInteger)attempt {
    if ([self isCancelled]) {
        [[self statusCheckTimer] invalidate];
        [self setStatusCheckTimer:nil];
        [self setCompleted:YES];
        return;
    }
    
    if (![[self statusCheckTimer] isValid]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    CGFloat delay = [self nextStatusCheckDelay:attempt];
    DDLogVerbose(@"checking next request after delay %f", delay);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [weakSelf checkStatus:attempt];
    });
}

- (BOOL)isExpectedStatus:(SENSleepSoundStatus*)status {
    return status
        && (([[self action] isKindOfClass:[SENSleepSoundRequestPlay class]] && [status isPlaying])
        || ([[self action] isKindOfClass:[SENSleepSoundRequestStop class]] && ![status isPlaying]));
}

#pragma mark - Errors

- (void)failWithError:(NSError*)error {
    [[self statusCheckTimer] invalidate];
    [self setStatusCheckTimer:nil];
    [self setActionError:error];
    [self setRunning:NO];
    [self setCompleted:YES];
}

#pragma mark - Timeouts

- (void)scheduleStatusTimer {
    NSTimer* timeout = [NSTimer scheduledTimerWithTimeInterval:HEMSleepSoundActionStatusTimeout
                                                        target:self
                                                      selector:@selector(timeout)
                                                      userInfo:nil
                                                       repeats:NO];
    [self setStatusCheckTimer:timeout];
}

- (void)timeout {
    [self failWithError:[NSError errorWithDomain:HEMSleepSoundActionErrorDomain
                                            code:HEMSleepSoundActionErrorStatusTimeout
                                        userInfo:nil]];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_statusCheckTimer) {
        [_statusCheckTimer invalidate];
    }
}

@end
