//
//  Mixpanel.m
//  mixpanel-simple
//
//  Created by Conrad Kramer on 10/2/14.
//  Copyright (c) 2014 DeskConnect. All rights reserved.
//

#import "Mixpanel.h"
#import "MPTracker.h"
#import "MPFlusher.h"
#import "MPPeople.h"

@implementation Mixpanel

- (instancetype)init {
    return [self initWithToken:nil cacheDirectory:nil];
}

- (instancetype)initWithToken:(NSString *)token cacheDirectory:(NSURL *)cacheDirectory {
    self = [super init];
    if (self) {
        NSURL *trackerCacheURL = [cacheDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"Mixpanel-%@.json", [token substringToIndex:6]]];
        NSURL *peopleCacheURL = [cacheDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"MixpanelPeople-%@.json", [token substringToIndex:6]]];
        _tracker = [[MPTracker alloc] initWithToken:token cacheURL:trackerCacheURL queueName:"com.mixpanel.mixpanel.tracker"];
        _flusher = [[MPFlusher alloc] initWithCacheDirectory:cacheDirectory];
        _people = [[MPPeople alloc] initWithToken:token cacheURL:peopleCacheURL queueName:"com.mixpanel.mixpanel.people"];

        if (!_tracker || !_flusher || !_people)
            return nil;
    }
    return self;
}

- (void)identify:(NSString *)distinctId {
    [self.tracker identify:distinctId];
    [self.people identify:distinctId];
}

@end
