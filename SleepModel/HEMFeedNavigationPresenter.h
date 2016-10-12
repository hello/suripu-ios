//
//  HEMFeedContentPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMDeviceService;
@class HEMUnreadAlertService;
@class HEMSubNavigationView;
@class HEMFeedNavigationPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMFeedNavigationDelegate <NSObject>

- (void)showInsightsFrom:(HEMFeedNavigationPresenter*)presenter;
- (void)showVoiceFrom:(HEMFeedNavigationPresenter*)presenter;

@end

@interface HEMFeedNavigationPresenter : HEMPresenter

@property (nonatomic, assign) id <HEMFeedNavigationDelegate> navDelegate;

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService
                        unreadService:(HEMUnreadAlertService*)unreadService;

- (void)bindWithTabBarItem:(UITabBarItem*)tabBarItem;
- (void)bindWithSubNavigationBar:(HEMSubNavigationView*)subNavgationBar
            withHeightConstraint:(NSLayoutConstraint*)heightConstraint;

@end

NS_ASSUME_NONNULL_END