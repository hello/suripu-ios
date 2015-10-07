//
//  SENAPIAppStats.m
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import "SENAPIAppStats.h"
#import "SENAppStats.h"
#import "SENAppUnreadStats.h"

static NSString* const SENAPIAppStatusEndpoint = @"v1/app/stats";
static NSString* const SENAPIAppStatusUnreadPath = @"unread";

@implementation SENAPIAppStats

+ (void)retrieveStats:(SENAPIDataBlock)completion {
    [SENAPIClient GET:SENAPIAppStatusEndpoint parameters:nil completion:^(id data, NSError *error) {
        SENAppStats* stats = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            stats = [[SENAppStats alloc] initWithDictionary:data];
        }
        completion (stats, error);
    }];
}

+ (void)updateStats:(SENAppStats*)stats completion:(SENAPIDataBlock)completion {
    NSDictionary* params = [stats dictionaryValue];
    [SENAPIClient PATCH:SENAPIAppStatusEndpoint parameters:params completion:completion];
}

+ (void)retrieveUnread:(SENAPIDataBlock)completion {
    NSString* path = [SENAPIAppStatusEndpoint stringByAppendingPathComponent:SENAPIAppStatusUnreadPath];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        SENAppUnreadStats* unreadStats = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            unreadStats = [[SENAppUnreadStats alloc] initWithDictionary:data];
        }
        completion (unreadStats, error);
    }];
}

@end
