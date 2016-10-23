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

@property (nonatomic, strong) HEMAlarmExpansionSetupPresenter* presenter;

@end

NS_ASSUME_NONNULL_END