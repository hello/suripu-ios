//
//  HEMSensorHandHoldingPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 1/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMHandHoldingService;

NS_ASSUME_NONNULL_BEGIN

@interface HEMSensorHandHoldingPresenter : HEMPresenter

- (instancetype)initWithService:(HEMHandHoldingService*)service;
- (void)showIfNeededIn:(UIView*)view withGraphView:(UIView*)graphView;
- (void)didCompleteSrubbingHandHolding;

@end

NS_ASSUME_NONNULL_END