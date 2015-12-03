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
}

- (void)updateTabBarItemUnreadIndicator {
    if ([self tabBarItem]) {
        SENAppUnreadStats* unreadStats = [[self unreadService] unreadStats];
        BOOL hasUnread = [unreadStats hasUnreadInsights] || [unreadStats hasUnreadQuestions];
        [[self tabBarItem] setBadgeValue:hasUnread ? @"1" : nil];
    }
}

- (void)didDisappear {
    [super didDisappear];
    [self updateTabBarItemUnreadIndicator];
}

@end
