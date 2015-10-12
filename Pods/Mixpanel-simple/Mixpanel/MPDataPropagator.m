//
//  MPDataPropagator.m
//  Mixpanel
//
//  Created by Delisa Mason on 9/25/15.
//  Copyright © 2015 DeskConnect. All rights reserved.
//

#import "MPDataPropagator.h"
#import "MPFlushOperation.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && !defined(__WATCH_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#endif

@interface MPDataPropagator ()
@property (nonatomic, strong) NSLock *distinctLock;
@property (nonatomic, strong) NSOperationQueue *flushOperationQueue;
@property (nonatomic, readwrite, copy) NSString *distinctId;
@end

@implementation MPDataPropagator

- (instancetype)init {
    self = [self initWithToken:nil cacheURL:nil queueName:nil];
    return self;
}

- (instancetype)initWithToken:(NSString *)token cacheURL:(NSURL *)cacheURL queueName:(const char *)queueName {
    if (self = [super init]) {
        if (!token.length) {
            NSLog(@"%@: Error: Invalid token provided: \"%@\"", self, token);
            return nil;
        }
        
        if (!cacheURL) {
            NSLog(@"%@: Error: Invalid cache URL provided: \"%@\"", self, cacheURL);
            return nil;
        }
        
        int fd;
        if ((fd = open(cacheURL.fileSystemRepresentation, O_WRONLY | O_APPEND | O_CREAT, 0644)) == -1) {
            NSLog(@"%@: Error: Cache URL is not writable: \"%@\"", self, cacheURL);
            return nil;
        }
        
        _token = token;
        _cacheURL = cacheURL;
        _distinctLock = [NSLock new];
        _handle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
        if (dispatch_queue_attr_make_with_qos_class)
#endif
            attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, QOS_MIN_RELATIVE_PRIORITY + 5);
        _queue = dispatch_queue_create(queueName, attr);
    }
    return self;
}

- (MPFlushOperationType)dataType {
    return MPFlushOperationTypeNone;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, token: %@>", NSStringFromClass([self class]), self, self.token];
}

- (BOOL)setFileHandleLocked:(BOOL)isLocked {
    if (isLocked) {
        if (flock(self.handle.fileDescriptor, LOCK_EX) == -1) {
            NSLog(@"%@: Error: Could not lock file descriptor", self);
            return NO;
        }
    } else if (flock(self.handle.fileDescriptor, LOCK_UN) == -1) {
        NSLog(@"%@: Error: Could not unlock file descriptor", self);
        return NO;
    }
    return YES;
}

- (BOOL)writePropertiesToDisk:(NSDictionary*)properties {
    if (!self.distinctId) {
        NSLog(@"%@: Error: Could not save events to disk without a distinctId", self);
        return NO;
    }
    
    NSError *error = nil;
    char endline = '\n';
    NSMutableData *data = [[NSJSONSerialization dataWithJSONObject:properties options:0 error:&error] mutableCopy];
    [data appendBytes:&endline length:1];
    if (!data) {
        NSLog(@"%@: Error: Properties \"%@\" could not be serialized", self, properties);
        return NO;
    }
    
    [self.handle writeData:data];
    [self.handle synchronizeFile];
    return YES;
}

#pragma mark - Identification

- (void)identify:(NSString *)distinctId {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.distinctLock lock];
        strongSelf.distinctId = distinctId;
        [strongSelf.distinctLock unlock];
    });
}

- (NSString *)distinctId {
    [_distinctLock lock];
    if (!_distinctId) {
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && !defined(__WATCH_OS_VERSION_MIN_REQUIRED)
        UIDevice *device = [UIDevice currentDevice];
        _distinctId = ([device respondsToSelector:@selector(identifierForVendor)] ? [device.identifierForVendor UUIDString] : nil);
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
        io_registry_entry_t ioRegistryRoot = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/");
        _distinctId = (__bridge_transfer NSString *)IORegistryEntryCreateCFProperty(ioRegistryRoot, CFSTR(kIOPlatformUUIDKey), kCFAllocatorDefault, 0);
        IOObjectRelease(ioRegistryRoot);
#endif
    }
    NSString *distinctId = _distinctId;
    [_distinctLock unlock];
    
    return distinctId;
}

#pragma mark - Flushing

- (void)flush:(void(^)())completion {
    if (!_flushOperationQueue)
        _flushOperationQueue = [NSOperationQueue new];

    MPFlushOperation *flushOperation = [[MPFlushOperation alloc] initWithCacheURL:_cacheURL type:[self dataType]];
    flushOperation.name = [NSString stringWithFormat:@"%@-%@", NSStringFromClass([self class]), [NSDate date]];
    flushOperation.completionBlock = completion;
    [_flushOperationQueue addOperation:flushOperation];
}

@end
