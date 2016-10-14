//
//  HEMSettingsNavigationController.h
//  Sense
//
//  Created by Jimmy Lu on 9/25/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMStyledNavigationViewController.h"

@interface HEMSettingsNavigationController : HEMStyledNavigationViewController

@property (nonatomic, assign) BOOL manuallyHandleDrawerVisibility;

/**
 *  Apply navigation bar styling
 */
- (void)configureNavigationBar;

@end
