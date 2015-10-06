//
//  HEMUnreadAlertService.h
//  Sense
//
//  Created by Jimmy Lu on 10/5/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

typedef void(^HEMUnreadCompletionHandler)(BOOL hasUnread, NSError* error);

typedef NS_ENUM(NSUInteger, HEMUnreadType) {
    HEMUnreadTypeInsights,
    HEMUnreadTypeQuestions
};

@class SENAppUnreadStats;

@interface HEMUnreadAlertService : SENService

@property (nonatomic, strong, readonly) SENAppUnreadStats* unreadStats;

+ (instancetype)sharedService;
- (void)update:(HEMUnreadCompletionHandler)completion;
- (void)updateLastViewFor:(HEMUnreadType)unreadType
               completion:(HEMUnreadCompletionHandler)completion;
- (BOOL)hasUnread;

@end
