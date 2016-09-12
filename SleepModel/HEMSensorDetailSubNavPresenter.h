//
//  HEMSensorDetailSubNavPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMSensorService;
@class HEMSubNavigationView;

@interface HEMSensorDetailSubNavPresenter : HEMPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService;
- (void)bindwithSubNavigationView:(HEMSubNavigationView*)subNav;

@end
