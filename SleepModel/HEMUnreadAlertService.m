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
        service = [[super allocWithZone:NULL] init];
    });
    return service;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedService];
}

- (BOOL)lastViewedIsToday {
    return [self lastReadStats]
        && [[[self lastReadStats] lastViewedInsights] isOnSameDay:[NSDate date]];
}

#pragma mark - Updates

- (void)udpateLastViewStats:(void(^)(NSError* error))completion {
    if ([self lastViewedIsToday]) {
        completion (nil);
        return;
    }
    
    [SENAPIAppStats stats:^(SENAppStats* stats, NSError *error) {
        if (!error) {
            [self setLastReadStats:stats];
        }
        completion (error);
    }];
}

- (void)updateUnread:(void(^)(NSError* error))completion {
    [SENAPIAppStats unread:^(SENAppUnreadStats* stats, NSError *error) {
        if (!error) {
            [self setUnreadStats:stats];
        }
        completion (error);
    }];
}

- (void)update:(HEMUnreadCompletionHandler)completion {
    // There can potentially be case where last viewed was today, but there are
    // stil unread items such as questions so we should check again in case user
    // has answered some questions
    if ([self lastViewedIsToday] && ![self hasUnread]) {
        if (completion) {
            completion ([self hasUnread], nil);
        }
        return;
    }
    
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
    NSDate* today = [NSDate date];
    if (![[[self lastReadStats] lastViewedInsights] isOnSameDay:today]) {
        SENAppStats* stats = [SENAppStats new];
        [stats setLastViewedInsights:today];
        [SENAPIAppStats updateStats:stats completion:^(id data, NSError *error) {
            [self update:completion];
        }];
    } else {
        if (completion) {
            completion ([self hasUnread], nil);
        }
    }
}

- (void)updateQuestionsReadStatus:(HEMUnreadCompletionHandler)completion {
    [self updateUnread:^(NSError *error) {
        if (completion) {
            completion ([self hasUnread], nil);
        }
    }];
}

#pragma mark - Unread

- (BOOL)hasUnread {
    return [[self unreadStats] hasUnreadInsights]
        || [[self unreadStats] hasUnreadQuestions];
}

@end
