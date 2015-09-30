//
//  MPFlushOperation.m
//  mixpanel-simple
//
//  Created by Conrad Kramer on 11/19/14.
//  Copyright (c) 2014 DeskConnect. All rights reserved.
//

#import "MPFlushOperation.h"
#import "MPTracker.h"
#import "MPUtilities.h"

extern NSString * const MPEventQueueKey;

@interface MPFlushOperation ()

@property (nonatomic, strong) NSFileHandle *handle;
@property (nonatomic) MPFlushOperationType type;
@end

@implementation MPFlushOperation

- (instancetype)init {
    return [self initWithCacheURL:nil type:MPFlushOperationTypeEvent];
}

- (instancetype)initWithCacheURL:(NSURL *)cacheURL type:(MPFlushOperationType)type {
    NSParameterAssert(cacheURL);
    if (self = [super init]) {
        NSError *error = nil;
        _handle = [NSFileHandle fileHandleForUpdatingURL:cacheURL error:&error];
        if (!_handle) {
            NSLog(@"%@: Error: %@", self, error.localizedDescription);
            return nil;
        }
        
        _cacheURL = [cacheURL copy];
        _type = type;
    }
    return self;
}

- (void)main {
    if (flock(_handle.fileDescriptor, LOCK_EX) == -1) {
        NSLog(@"%@: Error: Could not lock file descriptor", self);
        return;
    }
    
    FILE *file;
    if ((file = fopen(_cacheURL.fileSystemRepresentation, "r")) == NULL) {
        NSLog(@"%@: Error: Could not open file descriptor", self);
        if (flock(_handle.fileDescriptor, LOCK_UN) == -1)
            NSLog(@"%@: Error: Could unlock file descriptor", self);
        return;
    }
    
    char start = '[';
    char delim = ',';
    char end = ']';
    
    NSMutableData *body = [NSMutableData new];
    [body appendBytes:&start length:1];
    
    int line = 0;
    ssize_t length = -1;
    size_t n = 1024;
    char *lineptr = malloc(length);
    off_t offset = 0;
    while ((length = getline(&lineptr, &n, file)) > 0 && line < 50) {
        offset += length;
        
        NSError *error = nil;
        [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytesNoCopy:lineptr length:length freeWhenDone:NO] options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"%@: Error: Line is not valid JSON, skipping", self);
            continue;
        }
        [body appendBytes:lineptr length:(length - 1)];
        [body appendBytes:&delim length:1];
        line++;
    }
    
    [body replaceBytesInRange:NSMakeRange(body.length - 1, 1) withBytes:&end length:1];
    fclose(file);
    
    if (line == 0) {
        if (flock(_handle.fileDescriptor, LOCK_UN) == -1)
            NSLog(@"%@: Error: Could unlock file descriptor", self);
        return;
    }
    
    NSURLRequest *request = [self URLRequestForBody:body];
    if (!request) {
        NSLog(@"%@: Error: Failed to create request", self);
        if (flock(_handle.fileDescriptor, LOCK_UN) == -1)
            NSLog(@"%@: Error: Could unlock file descriptor", self);
        return;
    }

    __block NSError *error = nil;
    __block NSHTTPURLResponse *response = nil;
    __block NSData *responseData = nil;
    
    if ([NSURLSession class]) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *sessionData, NSURLResponse *sessionResponse, NSError *sessionError) {
            responseData = sessionData;
            response = (NSHTTPURLResponse *)sessionResponse;
            error = sessionError;
            dispatch_semaphore_signal(semaphore);
        }] resume];
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC));
    }
    
    NSIndexSet *acceptableCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    if (error || ![acceptableCodes containsIndex:response.statusCode]) {
        NSLog(@"%@: Error: Request failed: %@", self, error.localizedDescription);
        if (flock(_handle.fileDescriptor, LOCK_UN) == -1)
            NSLog(@"%@: Error: Could unlock file descriptor", self);
        return;
    }
    
    if ([[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] integerValue] != 1) {
        NSLog(@"%@: Error: Not all events accepted by server", self);
    }
    
    [_handle seekToFileOffset:offset];
    NSData *fileData = [_handle readDataToEndOfFile];
    [_handle seekToFileOffset:0];
    [_handle writeData:fileData];
    [_handle truncateFileAtOffset:fileData.length];
    
    if (flock(_handle.fileDescriptor, LOCK_UN) == -1)
        NSLog(@"%@: Error: Could unlock file descriptor", self);
}

- (NSURLRequest *)URLRequestForBody:(NSData *)body {
    switch (self.type) {
        case MPFlushOperationTypeEvent:
            return MPURLRequestForEventData(body);
        case MPFlushOperationTypePeople:
            return MPURLRequestForPeopleData(body);
        default:
            return nil;
    }
}

@end
