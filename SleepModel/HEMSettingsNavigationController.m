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

@property (nonatomic, assign) UIStatusBarStyle previousBarStyle;

@end

@implementation HEMSettingsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[HelloStyleKit backViewGraycolor]];
    [[self navigationBar] setTintColor:[HelloStyleKit backViewNavTintColor]];
    [[self navigationBar] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [HelloStyleKit backViewNavTintColor],
        NSFontAttributeName : [UIFont fontWithName:@"Calibre-Regular" size:20.0f]
    }];
}   

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[viewController view] setBackgroundColor:[HelloStyleKit backViewGraycolor]];
    [super pushViewController:viewController animated:animated];
}

@end
