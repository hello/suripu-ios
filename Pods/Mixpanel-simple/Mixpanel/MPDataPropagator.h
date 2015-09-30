//
//  MPDataPropagator.h
//  Mixpanel
//
//  Created by Delisa Mason on 9/25/15.
//  Copyright © 2015 DeskConnect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPFlushOperation.h"

@interface MPDataPropagator : NSObject

@property (nonatomic, readonly, copy) NSString *token;
@property (nonatomic, readonly, copy) NSString *distinctId;
@property (nonatomic, readonly, copy) NSURL *cacheURL;
@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, readonly) NSFileHandle* handle;

- (instancetype)initWithToken:(NSString *)token 
                     cacheURL:(NSURL *)cacheURL 
                    queueName:(const char *)queueName NS_DESIGNATED_INITIALIZER;
- (void)identify:(NSString *)distinctId;
- (BOOL)writePropertiesToDisk:(NSDictionary*)properties;
- (BOOL)setFileHandleLocked:(BOOL)isLocked;
- (void)flush:(void(^)())completion;
- (MPFlushOperationType)dataType;
@end
