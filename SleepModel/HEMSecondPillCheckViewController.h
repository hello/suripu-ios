//
//  HEMTwoPillSetupViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@protocol HEMSecondPillCheckDelegate <NSObject>

/**
 * @method checkController:isSettingUpNewSense
 *
 * @discussion
 * delegate method to let calling controller know what the user is doing.
 *
 * @param controller:        the check controller
 * @param settingUpNewSense: YES if new Sense set up, NO if adding new pill
 */
- (void)checkController:(UIViewController*)controller
    isSettingUpNewSense:(BOOL)settingUpNewSense;

@end

@interface HEMSecondPillCheckViewController : HEMOnboardingController

@property (nonatomic, assign) id<HEMSecondPillCheckDelegate> delegate;

@end
