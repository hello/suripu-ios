//
//  HEMUnreadAlertService.m
//  Sense
//
//  Created by Jimmy Lu on 10/5/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAPIAppStats.h>
#import <SenseKit/SENAppUnreadStats.h>
#import <SenseKit/SENAppStats.h>

#import "HEMUnreadAlertService.h"
#import "NSDate+HEMRelative.h"

@interface HEMUnreadAlertService()

@property (nonatomic, strong) SENAppUnreadStats* unreadStats;

@end

@implementation HEMUnreadAlertService

#pragma mark - Updates

- (void)updateUnread:(void(^)(NSError* error))completion {
    [SENAPIAppStats retrieveUnread:^(SENAppUnreadStats* stats, NSError *error) {
        if (!error && stats) {
            [self setUnreadStats:stats];
            DDLogVerbose(@"updated unread statuses, has unread %@", [self hasUnread] ? @"y" : @"n");
        }
        completion (error);
    }];
}

- (void)update:(HEMUnreadCompletionHandler)completion {
    [self updateUnread:^(NSError *error) {
        BOOL hasUnread = NO;
        if (!error) {
            hasUnread = [self hasUnread];
        }
        if (completion) {
            completion (hasUnread, error);
        }
    }];
}

- (void)updateLastViewFor:(HEMUnreadTypes)unreadTypes
               completion:(HEMUnreadCompletionHandler)completion {
    SENAppStats* stats = [SENAppStats new];
    NSDate *now = [NSDate date];
    if ((unreadTypes & HEMUnreadTypeInsights) == HEMUnreadTypeInsights) {
        [stats setLastViewedInsights:now];
    }
    if ((unreadTypes & HEMUnreadTypeQuestions) == HEMUnreadTypeQuestions) {
        [stats setLastViewedQuestions:now];
    }
    [SENAPIAppStats updateStats:stats completion:^(id data, NSError *error) {
        if (!error) {
            [self update:completion];
        } else {
            if (completion) {
                completion ([self hasUnread], error);
            }
        }
    }];
}

#pragma mark - Unread

- (BOOL)hasUnread {
    return ([[self unreadStats] hasUnreadInsights]
            || [[self unreadStats] hasUnreadQuestions]);
}

@end
