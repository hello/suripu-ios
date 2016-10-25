//
//  HEMVolumeControlViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBaseController.h"

@class HEMVoiceService;
@class SENSenseVoiceSettings;
@class HEMVolumeControlPresenter;

NS_ASSUME_NONNULL_BEGIN

@interface HEMVolumeControlViewController : HEMBaseController

@property (nonatomic, strong) HEMVolumeControlPresenter* presenter;

@end

NS_ASSUME_NONNULL_END