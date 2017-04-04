//
//  HEMSettingsNavigationController.m
//  Sense
//
//  Created by Jimmy Lu on 9/25/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"

#import "UIColor+HEMStyle.h"
#import "HEMSettingsNavigationController.h"

@interface HEMSettingsNavigationController()

@property (nonatomic, assign) UIStatusBarStyle previousBarStyle;

@end

@implementation HEMSettingsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self applyStyle];
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

- (void)applyStyle {
    [super applyStyle];
    
    UIImage* separatorImage = [UIImage imageNamed:@"navBorder"];
    UIColor* separatorColor = [SenseStyle colorWithAClass:[UINavigationBar class] property:ThemePropertySeparatorColor];
    separatorImage = [separatorImage imageWithTint:separatorColor];
    [[self navigationBar] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[self navigationBar] setShadowImage:separatorImage];
}

@end
