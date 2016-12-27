//
//  HEMSystemAlertPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMNetworkAlertService;
@class HEMDeviceAlertService;
@class HEMSystemAlertPresenter;
@class HEMTimeZoneAlertService;
@class HEMDeviceService;
@class HEMSystemAlertService;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMSystemAlertDelegate <NSObject>

- (void)presentViewController:(UIViewController*)controller from:(HEMSystemAlertPresenter*)presenter;
- (void)presentSupportPageWithSlug:(NSString*)supportPageSlug from:(HEMSystemAlertPresenter*)presenter;
- (void)dismissCurrentViewControllerFrom:(HEMSystemAlertPresenter*)presenter;

@end

@interface HEMSystemAlertPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMSystemAlertDelegate> delegate;
@property (nonatomic, assign, getter=isEnable) BOOL enable; // defaults to YES

- (instancetype)initWithNetworkAlertService:(HEMNetworkAlertService*)networkAlertService
                         deviceAlertService:(HEMDeviceAlertService*)deviceAlertService
                       timeZoneAlertService:(HEMTimeZoneAlertService*)tzAlertService
                              deviceService:(HEMDeviceService*)deviceService
                            sysAlertService:(HEMSystemAlertService*)alertService NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)bindWithContainerView:(UIView*)containerView below:(UIView*)topView;

@end

NS_ASSUME_NONNULL_END
