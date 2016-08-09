//
//  HEMHaveSenseViewController.h
//  Sense
//
//  Created by Jimmy Lu on 3/3/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMOnboardingController.h"

@class HEMNewSensePresenter;

@interface HEMHaveSenseViewController : HEMOnboardingController

@property (nonatomic, strong) HEMNewSensePresenter* presenter;
@property (nonatomic, assign, getter=shouldShowBackButtonAsCancel) BOOL showBackButtonAsCancel;

@end
