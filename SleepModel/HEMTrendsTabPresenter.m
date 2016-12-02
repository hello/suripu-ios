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
    [tabBarItem setImage:[UIImage imageNamed:@"trendsTabBarIcon"]];
    [tabBarItem setSelectedImage:[UIImage imageNamed:@"trendsTabBarIcon"]];
    [self setTabBarItem:tabBarItem];
}

@end
