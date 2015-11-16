//
//  HEMUnreadAlertService.h
//  Sense
//
//  Created by Jimmy Lu on 10/5/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

typedef void(^HEMUnreadCompletionHandler)(BOOL hasUnread, NSError* error);

typedef NS_OPTIONS(NSUInteger, HEMUnreadTypes) {
    HEMUnreadTypeInsights = (1 << 1),
    HEMUnreadTypeQuestions = (1 << 2),
};

@class SENAppUnreadStats;

@interface HEMUnreadAlertService : SENService

@property (nonatomic, strong, readonly) SENAppUnreadStats* unreadStats;

+ (instancetype)sharedService;
- (void)update:(HEMUnreadCompletionHandler)completion;
- (void)updateLastViewFor:(HEMUnreadTypes)unreadTypes
               completion:(HEMUnreadCompletionHandler)completion;

/**
 * @discussion
 * This is convenience method to check all properties of the unreadStats property
 * for anything unread.  This should only be used by a global unread / notification
 * indicator of something new
 *
 * @return YES if there is anything marked as unread / unanswered based on the
 *         latest SENAppUnreadStats object.  NO otherwise.
 */
- (BOOL)hasUnread;

@end
