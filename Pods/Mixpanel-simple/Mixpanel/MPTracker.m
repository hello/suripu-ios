//
//  MPTracker.m
//  mixpanel-simple
//
//  Created by Conrad Kramer on 11/16/14.
//  Copyright (c) 2014 DeskConnect. All rights reserved.
//

#import "MPTracker.h"
#import "MPUtilities.h"

@interface MPTracker ()
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSDate *>*timedEvents;
@property (nonatomic, strong) NSLock *timedEventLock;
@end

@implementation MPTracker

- (instancetype)init {
    return [self initWithToken:nil cacheURL:nil queueName:nil];
}

- (instancetype)initWithToken:(NSString *)token cacheURL:(NSURL *)cacheURL queueName:(const char *)queueName{
    if (self = [super initWithToken:token cacheURL:cacheURL queueName:queueName]) {
        _events = [NSArray new];
        _timedEvents = [NSMutableDictionary new];
        _timedEventLock = [NSLock new];
    }
    return self;
}

- (MPFlushOperationType)dataType {
    return MPFlushOperationTypeEvent;
}

- (void)track:(NSString *)event {
    [self track:event properties:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties {
    NSParameterAssert(event);

    NSNumber *timestamp = [NSNumber numberWithInteger:(NSUInteger)round([[NSDate date] timeIntervalSince1970])];

    NSMutableDictionary *mergedProperties = [NSMutableDictionary dictionaryWithDictionary:MPAutomaticProperties()];
    [mergedProperties addEntriesFromDictionary:properties];
    [mergedProperties setValue:timestamp forKey:@"time"];

    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *distinctId = strongSelf.distinctId;
        [strongSelf.timedEventLock lock];
        NSDate* startDate = strongSelf.timedEvents[event];
        [strongSelf.timedEventLock unlock];
        if (startDate) {
            NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:startDate];
            NSString* duration = [NSString stringWithFormat:@"%.3f", elapsed];
            mergedProperties[@"$duration"] = duration;
        }
        [mergedProperties addEntriesFromDictionary:strongSelf.defaultProperties];
        [mergedProperties setValue:distinctId forKey:@"distinct_id"];
        [mergedProperties setValue:strongSelf.token forKey:@"token"];

        if (![strongSelf setFileHandleLocked:YES])
            return;
        
        NSDictionary *eventDictionary = MPJSONSerializableObject([NSDictionary dictionaryWithObjectsAndKeys:event, @"event", mergedProperties, @"properties", nil]);
        _events = [_events arrayByAddingObject:eventDictionary];
        
        if (!distinctId) {
            NSLog(@"%@: Error: Could not save events to disk without a distinctId", strongSelf);
            return;
        }
                
        for (__strong NSDictionary *event in _events) {
            NSDictionary *properties = [event objectForKey:@"properties"];
            
            if (![properties objectForKey:@"distinct_id"]) {
                NSMutableDictionary *mutableEvent = [event mutableCopy];
                NSMutableDictionary *mutableProperties = [properties mutableCopy];
                [mutableProperties setObject:distinctId forKey:@"distinct_id"];
                [mutableEvent setObject:mutableProperties forKey:@"distinct_id"];
                event = mutableEvent;
            }
            
            if (![strongSelf writePropertiesToDisk:event])
                return;
        }
        
        _events = [NSArray new];
        [strongSelf setFileHandleLocked:NO];
    });
}

- (void)createAlias:(NSString *)alias forDistinctID:(NSString *)distinctID {
    if (!alias.length) {
        NSLog(@"%@: Error: Create alias called with invalid alias", self);
        return;
    }
    if (!distinctID.length) {
        NSLog(@"%@: Error: Create alias called with invalid distinct ID", self);
        return;
    }
    
    [self track:@"$create_alias" properties:@{@"distinct_id": distinctID, @"alias": alias}];
}

- (void)timeEvent:(NSString *)event {
    [self.timedEventLock lock];
    self.timedEvents[event] = [NSDate date];
    [self.timedEventLock unlock];
}

- (void)endEvent:(NSString *)event {
    [self track:event];
}


@end
