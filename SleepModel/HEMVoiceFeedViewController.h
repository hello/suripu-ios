//
//  HEMVoiceFeedViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBaseController.h"

@class HEMVoiceService;
@class HEMSubNavigationView;

@interface HEMVoiceFeedViewController : HEMBaseController

@property (nonatomic, strong) HEMVoiceService* voiceService;
@property (nonatomic, weak) HEMSubNavigationView* subNavBar;

@end
