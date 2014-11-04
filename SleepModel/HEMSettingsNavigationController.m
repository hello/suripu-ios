//
//  HEMSettingsNavigationController.m
//  Sense
//
//  Created by Jimmy Lu on 9/25/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMSettingsNavigationController.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

@interface HEMSettingsNavigationController()

@property (nonatomic, assign) UIStatusBarStyle previousBarStyle;

@end

@implementation HEMSettingsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[HelloStyleKit backViewBackgroundColor]];
    [[self navigationBar] setTintColor:[HelloStyleKit backViewTintColor]];
    [[self navigationBar] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [HelloStyleKit backViewNavTitleColor],
        NSFontAttributeName : [UIFont settingsTitleFont]
    }];
}   

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[viewController view] setBackgroundColor:[HelloStyleKit backViewBackgroundColor]];
    [super pushViewController:viewController animated:animated];
}

@end
