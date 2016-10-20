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

NS_ASSUME_NONNULL_BEGIN

@interface HEMVolumeControlViewController : HEMBaseController

@property (nonatomic, strong, nullable) HEMVoiceService* voiceService;
@property (nonatomic, strong, nullable) SENSenseVoiceSettings* voiceSettings;
@property (nonatomic, copy, nullable) NSString* senseId;

@end

NS_ASSUME_NONNULL_END