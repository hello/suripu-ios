//
//  HEMInsightTabPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/15/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAppUnreadStats.h>

#import "HEMInsightTabPresenter.h"
#import "HEMUnreadAlertService.h"
#import "HelloStyleKit.h"

@interface HEMInsightTabPresenter()

@property (nonatomic, weak) HEMUnreadAlertService* unreadService;
@property (nonatomic, weak) UITabBarItem* tabBarItem;

@end

@implementation HEMInsightTabPresenter

- (nonnull instancetype)initWithUnreadService:(nonnull HEMUnreadAlertService*)unreadService {
    self = [super init];
    if (self) {
        _unreadService = unreadService;
    }
    return self;
}

- (void)bindWithTabBarItem:(nonnull UITabBarItem*)tabBarItem {
    tabBarItem.title = NSLocalizedString(@"insights.title", nil);
    tabBarItem.image = [HelloStyleKit senseBarIcon];
    tabBarItem.selectedImage = [UIImage imageNamed:@"senseBarIconActive"];
    [self setTabBarItem:tabBarItem];
    [self updateTabBarItemUnreadIndicator];
}

- (void)updateTabBarItemUnreadIndicator {
    if ([self tabBarItem]) {
        // since the service is shared, if the last viewed is updated, the stats
        // will to, so we don't need to ask the service to update again.  Also
        // because the SnazzBarController indirectly depends on the tabBarItem,
        // updating the tabBar doesn't really have an effect immediately, which
        // is partially why we don't want to make an async call here
        
        SENAppUnreadStats* unreadStats = [[self unreadService] unreadStats];
        if (unreadStats) {
            [self updateBadge];
        } else {
            __weak typeof(self) weakSelf = self;
            [[self unreadService] update:^(BOOL hasUnread, NSError *error) {
                [weakSelf updateBadge];
            }];
        }
    }
}

- (void)updateBadge {
    SENAppUnreadStats* unreadStats = [[self unreadService] unreadStats];
    BOOL hasUnreadFeedItems = [unreadStats hasUnreadInsights] || [unreadStats hasUnreadQuestions];
    [[self tabBarItem] setBadgeValue:hasUnreadFeedItems ? @"1" : nil];
}

- (void)willDisappear {
    [super willDisappear];
    [self updateTabBarItemUnreadIndicator];
}

@end
