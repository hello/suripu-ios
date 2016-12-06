//
//  HEMSettingsNavigationController.m
//  Sense
//
//  Created by Jimmy Lu on 9/25/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMSettingsNavigationController.h"

@interface HEMSettingsNavigationController()

@property (nonatomic, assign) UIStatusBarStyle previousBarStyle;

@end

@implementation HEMSettingsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor backgroundColor]];
    
    [self configureNavigationBar];
}

- (void)configureNavigationBar {
    [[self navigationBar] setBarTintColor:[UIColor navigationBarColor]];
    [[self navigationBar] setTranslucent:NO];
    [[self navigationBar] setClipsToBounds:NO];
    [[self navigationBar] setShadowImage:[UIImage imageNamed:@"navBorder"]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.interactivePopGestureRecognizer.enabled = NO;
    [[viewController view] setBackgroundColor:[UIColor backgroundColor]];
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    self.interactivePopGestureRecognizer.enabled = ![viewController isEqual:[self.viewControllers firstObject]];
}

@end
