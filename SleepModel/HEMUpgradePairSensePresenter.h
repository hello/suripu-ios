//
//  HEMUpgradePairSensePresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPairSensePresenter.h"

@interface HEMUpgradePairSensePresenter : HEMPairSensePresenter

@property (nonatomic, assign, getter=isCancellable) BOOL cancellable;

- (instancetype)initWithOnboardingService:(HEMOnboardingService *)onbService
                         andDeviceService:(SENServiceDevice*)deviceService;

@end
