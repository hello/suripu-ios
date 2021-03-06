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

NSString* const kHEMUnreadAlertNotificationUpdate = @"kHEMUnreadAlertNotificationUpdate";

@interface HEMUnreadAlertService()

@property (nonatomic, strong) SENAppUnreadStats* unreadStats;

@end

@implementation HEMUnreadAlertService

#pragma mark - Notifications

- (void)notifyOfUpdate {
    [self notify:kHEMUnreadAlertNotificationUpdate];
}

- (void)notify:(NSString*)name {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:self];
}

#pragma mark - Updates

- (void)update:(HEMUnreadCompletionHandler)completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAppStats retrieveUnread:^(SENAppUnreadStats* stats, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error && stats) {            
            [strongSelf setUnreadStats:stats];
            [strongSelf notifyOfUpdate];
        }
        if (completion) {
            completion ([strongSelf hasUnread], error);
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
    
    __weak typeof(self) weakSelf = self;
    [SENAPIAppStats updateStats:stats completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf update:completion];
        } else {
            if (completion) {
                completion ([strongSelf hasUnread], error);
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
