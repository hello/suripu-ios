//
//  HEMSettingsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMDeviceService;
@class HEMExpansionService;
@class HEMBreadcrumbService;
@class HEMActivityIndicatorView;
@class HEMSettingsPresenter;

typedef NS_ENUM(NSUInteger, HEMSettingsCategory) {
    HEMSettingsCategoryProfile = 0,
    HEMSettingsCategoryDevices,
    HEMSettingsCategoryNotifications,
    HEMSettingsCategoryExpansions,
    HEMSettingsCategoryVoice,
    HEMSettingsCategorySupport,
    HEMSettingsCategoryTellFriend
};

NS_ASSUME_NONNULL_BEGIN

@protocol HEMSettingsDelegate <NSObject>

- (void)didSelectSettingsCategory:(HEMSettingsCategory)section
                    fromPresenter:(HEMSettingsPresenter*)presenter;

- (void)showController:(UIViewController*)controller
         fromPresenter:(HEMSettingsPresenter*)presenter;

@end

@interface HEMSettingsPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMSettingsDelegate> delegate;

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService
                     expansionService:(HEMExpansionService*)expansionService
                    breadCrumbService:(HEMBreadcrumbService*)breadcrumbService;

- (void)bindWithTableView:(UITableView*)tableView;

- (void)bindWithActivityView:(HEMActivityIndicatorView*)activityView;

@end

NS_ASSUME_NONNULL_END