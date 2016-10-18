//
//  HEMVoiceSettingsViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMDeviceService;
@class HEMVoiceService;

@interface HEMVoiceSettingsViewController : HEMBaseController

@property (nonatomic, strong) HEMDeviceService* deviceService;
@property (nonatomic, strong) HEMVoiceService* voiceService;

@end
