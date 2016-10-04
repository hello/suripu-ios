//
//  HEMConfigurationsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListPresenter.h"
#import "HEMExpansionConnectDelegate.h"

@class SENExpansionConfig;
@class HEMExpansionService;
@class SENExpansion;

@interface HEMConfigurationsPresenter : HEMListPresenter

- (instancetype)initWithConfigs:(NSArray<SENExpansionConfig*>*)configs
                   forExpansion:(SENExpansion*)expansion
               expansionService:(HEMExpansionService*)service;

@property (nonatomic, weak) id<HEMExpansionConnectDelegate> connectDelegate;

@end
