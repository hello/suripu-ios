//
//  HEMConfigurationsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"
#import "HEMExpansionConnectDelegate.h"

@class SENExpansionConfig;
@class HEMExpansionService;
@class SENExpansion;
@class HEMActionButton;
@class HEMConfigurationsPresenter;

@protocol HEMConfigurationsDelegate <NSObject>

- (void)dismissConfigurationFrom:(HEMConfigurationsPresenter*)presenter;

@end

@interface HEMConfigurationsPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMExpansionConnectDelegate> connectDelegate;
@property (nonatomic, weak) id<HEMConfigurationsDelegate> configDelegate;

- (instancetype)initWithConfigs:(NSArray<SENExpansionConfig*>*)configs
                   forExpansion:(SENExpansion*)expansion
               expansionService:(HEMExpansionService*)service;
- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel;
- (void)bindWithTableView:(UITableView*)tableView;
- (void)bindWithActivityContainer:(UIView*)activityContainerView;
- (void)bindWithSkipButton:(UIButton*)skipButton;
- (void)bindWithDoneButton:(HEMActionButton*)doneButton;

@end
