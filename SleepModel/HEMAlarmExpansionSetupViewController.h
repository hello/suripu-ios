//
//  HEMAlarmExpansionSetupViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENExpansion.h>

#import "HEMBaseController.h"
#import "HEMAlarmExpansionSetupPresenter.h"

@class SENExpansion;
@class HEMExpansionService;
@class SENAlarmExpansion;

NS_ASSUME_NONNULL_BEGIN

@interface HEMAlarmExpansionSetupViewController : HEMBaseController

@property (nonatomic, strong) SENExpansion* expansion;
@property (nonatomic, strong) SENAlarmExpansion* alarmExpansion;
@property (nonatomic, strong) HEMExpansionService* expansionService;
@property (nonatomic, weak) id<HEMAlarmExpansionSetupDelegate> setupDelegate;

@end

NS_ASSUME_NONNULL_END