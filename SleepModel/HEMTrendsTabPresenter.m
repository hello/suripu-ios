//
//  HEMTrendsTabPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsTabPresenter.h"

@interface HEMTrendsTabPresenter()

@property (nonatomic, weak) UITabBarItem* tabBarItem;

@end

@implementation HEMTrendsTabPresenter

- (void)bindWithTabBarItem:(UITabBarItem*)tabBarItem {
    [tabBarItem setTitle:NSLocalizedString(@"trends.title", nil)];
    [tabBarItem setImage:[UIImage imageNamed:@"trendsBarIcon"]];
    [tabBarItem setSelectedImage:[UIImage imageNamed:@"trendsBarIconActive"]];
    [self setTabBarItem:tabBarItem];
}

@end
