//
//  HEMVoiceSettingsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMVoiceService;
@class HEMDeviceService;
@class HEMActivityIndicatorView;
@class HEMVoiceSettingsPresenter;
@class SENSenseVoiceSettings;
@class HEMVolumeControlPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMVoiceSettingsDelegate <NSObject>

- (void)showVolumeControlWithPresenter:(HEMVolumeControlPresenter*)volumePresenter
                         fromPresenter:(HEMVoiceSettingsPresenter*)presenter;

@end

@interface HEMVoiceSettingsPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMVoiceSettingsDelegate> delegate;

- (instancetype)initWithVoiceService:(HEMVoiceService*)voiceService
                       deviceService:(HEMDeviceService*)deviceService;

- (void)bindWithTableView:(UITableView*)tableView;

- (void)bindWithNavigationItem:(UINavigationItem*)navItem;

- (void)bindWithActivityContainer:(UIView*)activityContainer;

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicatorView;

@end

NS_ASSUME_NONNULL_END