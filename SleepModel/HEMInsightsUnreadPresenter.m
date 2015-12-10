//
//  HEMInsightsUnreadPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAppUnreadStats.h>

#import "HEMInsightsUnreadPresenter.h"
#import "HEMUnreadAlertService.h"
#import "HelloStyleKit.h"

@interface HEMInsightsUnreadPresenter()

@property (nonatomic, weak) HEMUnreadAlertService* unreadService;
@property (nonatomic, weak) UITabBarItem* tabBarItem;

@end

@implementation HEMInsightsUnreadPresenter

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
        __weak typeof(self) weakSelf = self;
        [[self unreadService] update:^(BOOL hasUnread, NSError *error) {
            if (!error) {
                SENAppUnreadStats* unreadStats = [[weakSelf unreadService] unreadStats];
                BOOL hasUnreadFeedItems = [unreadStats hasUnreadInsights] || [unreadStats hasUnreadQuestions];
                [[weakSelf tabBarItem] setBadgeValue:hasUnreadFeedItems ? @"1" : nil];
            }
        }];

    }
}

- (void)didDisappear {
    [super didDisappear];
    [self updateTabBarItemUnreadIndicator];
}

@end
