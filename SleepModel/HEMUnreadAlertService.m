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
@property (nonatomic, strong) SENAppStats* lastReadStats;

@end

@implementation HEMUnreadAlertService

+ (instancetype)sharedService {
    static HEMUnreadAlertService* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super alloc] init];
    });
    return service;
}

#pragma mark - Updates

- (void)udpateLastViewStats:(void(^)(NSError* error))completion {
    [SENAPIAppStats retrieveStats:^(SENAppStats* stats, NSError *error) {
        if (!error && stats) {
            [self setLastReadStats:stats];
        }
        completion (error);
    }];
}

- (void)updateUnread:(void(^)(NSError* error))completion {
    [SENAPIAppStats retrieveUnread:^(SENAppUnreadStats* stats, NSError *error) {
        if (!error && stats) {
            DDLogVerbose(@"updated unread statuses, has unread %@", [self hasUnread] ? @"y" : @"n");
            [self setUnreadStats:stats];
        }
        completion (error);
    }];
}

- (void)update:(HEMUnreadCompletionHandler)completion {
    [self udpateLastViewStats:^(NSError* error) {
        if (!error) {
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
    }];
}

- (void)updateLastViewFor:(HEMUnreadType)unreadType
               completion:(HEMUnreadCompletionHandler)completion {
    // not everything needs to update / pull everything
    switch (unreadType) {
        case HEMUnreadTypeInsights: {
            [self updateInsightsLastViewed:completion];
            break;
        }
        case HEMUnreadTypeQuestions: {
            [self updateQuestionsReadStatus:completion];
            break;
        }
        default: {
            if (completion) {
                completion ([self hasUnread], nil);
            }
            break;
        }
    }
}

- (void)updateInsightsLastViewed:(HEMUnreadCompletionHandler)completion {
    SENAppStats* stats = [SENAppStats new];
    [stats setLastViewedInsights:[NSDate date]];
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

- (void)updateQuestionsReadStatus:(HEMUnreadCompletionHandler)completion {
    [self updateUnread:^(NSError *error) {
        if (completion) {
            completion ([self hasUnread], error);
        }
    }];
}

#pragma mark - Unread

- (BOOL)hasUnread {
    return [[self unreadStats] hasUnreadInsights]
        || [[self unreadStats] hasUnreadQuestions];
}

@end
