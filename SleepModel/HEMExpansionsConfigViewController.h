//
//  HEMExpansionsConfigViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/4/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBaseController.h"
#import "HEMExpansionConnectDelegate.h"

@class HEMExpansionService;
@class SENExpansion;
@class SENExpansionConfig;

NS_ASSUME_NONNULL_BEGIN

@interface HEMExpansionsConfigViewController : HEMBaseController

@property (nonatomic, strong, nullable) NSArray<SENExpansionConfig*>* configs;
@property (nonatomic, strong, nullable) HEMExpansionService* expansionService;
@property (nonatomic, strong) SENExpansion* expansion;
@property (nonatomic, weak) id<HEMExpansionConnectDelegate> connectDelegate;

@end

NS_ASSUME_NONNULL_END