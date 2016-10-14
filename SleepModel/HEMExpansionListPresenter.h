//
//  HEMExpansionsListPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 9/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@class HEMExpansionService;
@class HEMActivityIndicatorView;
@class HEMExpansionListPresenter;

@protocol HEMExpansionActionDelegate <NSObject>

- (void)shouldShowExpansion:(SENExpansion*)expansion fromPresenter:(HEMExpansionListPresenter*)presenter;

@end

@interface HEMExpansionListPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMExpansionActionDelegate> actionDelegate;

- (instancetype)initWithExpansionService:(HEMExpansionService*)service;
- (void)bindWithTableView:(UITableView*)tableView;
- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator;

@end

NS_ASSUME_NONNULL_END