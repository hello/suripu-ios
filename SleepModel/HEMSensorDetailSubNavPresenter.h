//
//  HEMSensorDetailSubNavPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"
#import "HEMSensorService.h"

@class HEMSubNavigationView;
@class HEMSensorDetailSubNavPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMSensorDetailSubNavDelegate <NSObject>

- (void)didChangeScopeTo:(HEMSensorServiceScope)scope
           fromPresenter:(HEMSensorDetailSubNavPresenter*)presenter;

@end

@interface HEMSensorDetailSubNavPresenter : HEMPresenter

@property (nonatomic, assign, readonly) HEMSensorServiceScope scopeSelected;
@property (nonatomic, weak) id<HEMSensorDetailSubNavDelegate> delegate;

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService;
- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNav;
- (void)bindWithNavBar:(UINavigationBar*)navBar;
- (BOOL)hasNavBar;

@end

NS_ASSUME_NONNULL_END