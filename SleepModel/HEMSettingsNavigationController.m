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

@interface HEMSettingsNavigationController()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

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
    __weak typeof(self) weakSelf = self;
    self.interactivePopGestureRecognizer.delegate = weakSelf;
    self.delegate = weakSelf;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.interactivePopGestureRecognizer.enabled = NO;
    [self setBackButtonOnViewController:viewController];
    [[viewController view] setBackgroundColor:[HelloStyleKit backViewBackgroundColor]];
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
    self.interactivePopGestureRecognizer.enabled = YES;
}

- (void)setBackButtonOnViewController:(UIViewController*)viewController {
    UIImage* defaultBackImage = [HelloStyleKit backIcon];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithImage:defaultBackImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [item setTintColor:[HelloStyleKit barButtonEnabledColor]];
    [item setAccessibilityLabel:self.topViewController.title];
    viewController.navigationItem.leftBarButtonItem = item;
}

- (void)goBack {
    [self popViewControllerAnimated:YES];
}

@end
