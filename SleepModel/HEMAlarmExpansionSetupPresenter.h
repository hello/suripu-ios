//
//  HEMAlarmExpansionSetupPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENExpansion.h>

#import "HEMPresenter.h"

@class HEMAlarmExpansionSetupPresenter;
@class HEMExpansionService;
@class SENAlarmExpansion;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMAlarmExpansionSetupDelegate <NSObject>

- (void)updatedAlarmExpansion:(SENAlarmExpansion*)alarmExpansion
   withExpansionConfiguration:(SENExpansionConfig*)config;

@end

@protocol HEMAlarmExpansionActionDelegate <NSObject>

- (void)showExpansionInfoFrom:(HEMAlarmExpansionSetupPresenter*)presenter;
- (void)showController:(UIViewController*)controller
         fromPresenter:(HEMAlarmExpansionSetupPresenter*)presenter;

@end

@interface HEMAlarmExpansionSetupPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMAlarmExpansionSetupDelegate> delegate;
@property (nonatomic, weak) id<HEMAlarmExpansionActionDelegate> actionDelegate;

- (instancetype)initWithExpansion:(SENExpansion*)expansion
                   alarmExpansion:(nullable SENAlarmExpansion*)alarmExpansion
                 expansionService:(HEMExpansionService*)expansionService;

- (void)bindWithTableView:(UITableView*)tableView;

- (void)bindWithNavigationItem:(UINavigationItem*)navItem;

@end

NS_ASSUME_NONNULL_END