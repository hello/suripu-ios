//
//  MPPeople.m
//  Mixpanel
//
//  Created by Delisa Mason on 9/25/15.
//  Copyright © 2015 DeskConnect. All rights reserved.
//

#import "MPPeople.h"
#import "MPUtilities.h"

@interface MPPeople ()
@property (nonatomic, strong) NSArray* peopleUpdates;
@end

@implementation MPPeople

- (instancetype)initWithToken:(NSString *)token cacheURL:(NSURL *)cacheURL {
    if (token.length == 0 || !cacheURL)
        return nil;
    if (self = [super init]) {
        _peopleUpdates = [NSArray new];
    }
    return self;
}

- (MPFlushOperationType)dataType {
    return MPFlushOperationTypePeople;
}

- (void)setUserProperties:(NSDictionary *)properties {
    NSParameterAssert(properties);
    if (properties.count == 0)
        return;

    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![strongSelf setFileHandleLocked:YES])
            return;

        NSString* distinctId = strongSelf.distinctId;
        NSString* token = strongSelf.token;
        if (!distinctId || !token) {
            NSLog(@"%@: Error: Could not save events to disk without a distinctId and token", self);
            return;
        }
        NSDictionary* people = MPJSONSerializableObject(@{@"$token":token,
                                                          @"$distinct_id":distinctId,
                                                          @"$set":properties});
        strongSelf.peopleUpdates = [strongSelf.peopleUpdates arrayByAddingObject:people];
        if (![strongSelf writePropertiesToDisk:people])
            return;

        strongSelf.peopleUpdates = [NSArray new];
        [strongSelf setFileHandleLocked:NO];
    });
}

@end
