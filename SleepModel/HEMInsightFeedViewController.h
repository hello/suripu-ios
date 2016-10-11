//
//  HEMInsightFeedViewController.h
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMUnreadAlertService;
@class HEMSubNavigationView;

@interface HEMInsightFeedViewController : HEMBaseController

@property (nonatomic, strong) HEMUnreadAlertService* unreadService;
@property (nonatomic, weak) HEMSubNavigationView* subNavBar;

@end
