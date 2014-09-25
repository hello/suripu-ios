//
//  HEMSettingsNavigationController.m
//  Sense
//
//  Created by Jimmy Lu on 9/25/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSettingsNavigationController.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

@interface HEMSettingsNavigationController()

@end

@implementation HEMSettingsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundGradientLayer:[self view]];
    [[self navigationBar] setTintColor:[UIColor whiteColor]];
}

- (void)addBackgroundGradientLayer:(UIView*)view {
    CAGradientLayer* layer = [CAGradientLayer layer];
    [layer setFrame:[view bounds]];
    [HEMColorUtils configureLayer:layer forHourOfDay:24]; // midnight
    [[view layer] insertSublayer:layer atIndex:0];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self addBackgroundGradientLayer:[viewController view]];
    [super pushViewController:viewController animated:animated];
}

@end
