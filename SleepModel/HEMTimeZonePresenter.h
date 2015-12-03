//
//  HEMTimeZonePresenter.h
//  Sense
//
//  Created by Jimmy Lu on 11/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMTimeZoneService.h"
#import "HEMPresenter.h"

@class HEMBaseController;
@class HEMTimeZoneService;

typedef void(^HEMTimeZonePresenterDoneBlock)(void);

@interface HEMTimeZonePresenter : HEMPresenter

- (nonnull instancetype)initWithService:(nonnull HEMTimeZoneService*)service
                             controller:(nonnull HEMBaseController*)controller;
- (void)bindTableView:(nonnull UITableView*)tableView whenDonePerform:(nonnull HEMTimeZonePresenterDoneBlock)action;
- (void)bindNavigationItem:(nonnull UINavigationItem*)navigationItem withAction:(nonnull SEL)action;

@end
