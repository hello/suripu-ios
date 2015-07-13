//
//  HEMStyledNavigationViewController.m
//  Sense
//
//  Created by Delisa Mason on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMStyledNavigationViewController.h"
#import "HelloStyleKit.h"
#import "HEMScreenUtils.h"
#import "UIFont+HEMStyle.h"

@interface HEMStyledNavigationViewController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation HEMStyledNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationBar] setTintColor:[HelloStyleKit backViewTintColor]];
    UIFont* titleFont = HEMIsIPhone4Family()
        ? [UIFont iPhone4SSettingsTitleFont]
        : [UIFont settingsTitleFont];
    [[self navigationBar] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [HelloStyleKit backViewNavTitleColor],
        NSFontAttributeName : titleFont
    }];
    
    // required since we are adding custom back button
    __weak typeof(self) weakSelf = self;
    self.interactivePopGestureRecognizer.delegate = weakSelf;
    self.delegate = weakSelf;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self setBackButtonOnViewController:viewController];
    [super pushViewController:viewController animated:animated];
}

- (void)setBackButtonOnViewController:(UIViewController*)viewController {
    UIImage* defaultBackImage = [HelloStyleKit backIcon];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithImage:defaultBackImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [item setTintColor:[HelloStyleKit tintColor]];
    [item setAccessibilityLabel:self.topViewController.title];
    viewController.navigationItem.leftBarButtonItem = item;
}

- (void)goBack {
    [self popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UIViewController* rootController = [self.viewControllers firstObject];
    UIView* rootView = rootController.view;
    while (rootView && ![rootView isKindOfClass:[UIWindow class]]) {
        if (rootView == gestureRecognizer.view)
            return NO;
        rootView = [rootView superview];
    }
    return YES;
}

@end
