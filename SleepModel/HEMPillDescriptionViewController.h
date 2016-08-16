//
//  HEMPillDescriptionViewController.h
//  Sense
//
//  Created by Jimmy Lu on 2/3/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMOnboardingController.h"

@class HEMPillDescriptionPresenter;

@interface HEMPillDescriptionViewController : HEMOnboardingController

@property (nonatomic, strong) HEMPillDescriptionPresenter* presenter;

@end
