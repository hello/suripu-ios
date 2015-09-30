//
//  MPFlusher.m
//  mixpanel-simple
//
//  Created by Conrad Kramer on 11/19/14.
//  Copyright (c) 2014 DeskConnect. All rights reserved.
//

#import "MPFlusher.h"
#import "MPFlushOperation.h"

@implementation MPFlusher {
    NSTimer *_flushTimer;
    NSOperationQueue *_flushOperationQueue;
}

- (instancetype)init {
    return [self initWithCacheDirectory:nil];
}

- (instancetype)initWithCacheDirectory:(NSURL *)cacheDirectory {
    self = [super init];
    if (self) {
        BOOL directory = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory.path isDirectory:&directory] || !directory) {
            NSLog(@"%@: Invalid cache directory provided", self);
            return nil;
        }

        _cacheDirectory = [cacheDirectory copy];
        _flushOperationQueue = [NSOperationQueue new];
        
        [self setFlushInterval:15.0f];
    }
    return self;
}

- (NSTimeInterval)flushInterval {
    return _flushTimer.timeInterval;
}

- (void)setFlushInterval:(NSTimeInterval)flushInterval {
    [_flushTimer invalidate];
    NSTimer *flushTimer = [NSTimer timerWithTimeInterval:flushInterval target:self selector:@selector(flush) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:flushTimer forMode:NSRunLoopCommonModes];
    _flushTimer = flushTimer;
    [_flushTimer fire];
}

- (void)flush {
    NSSet *queuedURLs = [NSSet setWithArray:[_flushOperationQueue.operations valueForKey:NSStringFromSelector(@selector(cacheURL))]];
    NSDirectoryEnumerator *cacheEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:_cacheDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^(NSURL *url, NSError *error) {
        return YES;
    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"path ENDSWITH '.json'"];
    for (__strong NSURL *cacheURL in cacheEnumerator) {
        cacheURL = [cacheURL URLByResolvingSymlinksInPath];
        if ([predicate evaluateWithObject:cacheURL]) {
            if (![queuedURLs containsObject:cacheURL]) {
                MPFlushOperation *operation = [[MPFlushOperation alloc] initWithCacheURL:cacheURL type:[self typeForCacheURL:cacheURL]];
                operation.name = [NSString stringWithFormat:@"%@-%@", NSStringFromClass([self class]), [NSDate date]];
                [_flushOperationQueue addOperation:operation];
            }
        }
    }
}

- (MPFlushOperationType)typeForCacheURL:(NSURL *)cacheURL {
    if ([cacheURL.path containsString:@"People"]) {
        return MPFlushOperationTypePeople;
    }
    return MPFlushOperationTypeEvent;
}

@end
