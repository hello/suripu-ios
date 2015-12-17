//
//  HEMInsightTabPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/15/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMUnreadAlertService;

@interface HEMInsightTabPresenter : HEMPresenter

- (nonnull instancetype)initWithUnreadService:(nonnull HEMUnreadAlertService*)unreadService;

- (void)bindWithTabBarItem:(nonnull UITabBarItem*)tabBarItem;

@end
