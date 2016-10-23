//
//  HEMVolumeControlPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMActionButton;
@class HEMVoiceService;
@class SENSenseVoiceSettings;
@class HEMVolumeSlider;
@class HEMVolumeControlPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMVolumeControlDelegate <NSObject>

- (void)dismissControlFrom:(HEMVolumeControlPresenter*)presenter;

@end

@protocol HEMVolumeControlUpdateDelegate <NSObject>

- (void)updatedVolumeFromPresenter:(HEMVolumeControlPresenter*)presenter;

@end

@interface HEMVolumeControlPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMVolumeControlDelegate> delegate;
@property (nonatomic, weak) id<HEMVolumeControlUpdateDelegate> updateDelegate;

- (instancetype)initWithVoiceSettings:(SENSenseVoiceSettings*)voiceSettings
                              senseId:(NSString*)senseId
                         voiceService:(HEMVoiceService*)voiceService;

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel
  descriptionTopConstraint:(NSLayoutConstraint*)descriptionTopConstraint;
- (void)bindWithVolumeLabel:(UILabel*)volumeLabel volumeSlider:(HEMVolumeSlider*)volumeSlider;
- (void)bindWithCancelButton:(UIButton*)cancelButton saveButton:(HEMActionButton*)saveButton;
- (void)bindWithNavigationItem:(UINavigationItem*)navItem;
- (void)bindWithActivityContainer:(UIView*)activityContainer;

@end

NS_ASSUME_NONNULL_END