//
//  HEMUpgradePillDescriptionPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPillDescriptionPresenter.h"

@class SENServiceDevice;
@class HEMOnboardingService;

@interface HEMUpgradePillDescriptionPresenter : HEMPillDescriptionPresenter

/**
 * @discussion
 * Initialize with the device service, holding it with a strong reference
 *
 * @param deviceService: service to manage devices, particularly the pill
 * @param onboardingService: the service that was used throughout the upgrade path
 */
- (instancetype)initWithDeviceService:(SENServiceDevice*)deviceService
                    onboardingService:(HEMOnboardingService*)onboardingService NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end
