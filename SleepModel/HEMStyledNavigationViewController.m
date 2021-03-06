//
//  HEMStyledNavigationViewController.m
//  Sense
//
//  Created by Delisa Mason on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"

#import "HEMStyledNavigationViewController.h"
#import "HEMScreenUtils.h"

@interface HEMStyledNavigationViewController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation HEMStyledNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // required since we are adding custom back button
    __weak typeof(self) weakSelf = self;
    self.interactivePopGestureRecognizer.delegate = weakSelf;
    self.delegate = weakSelf;
    [self applyStyle];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[SenseStyle theme] statusBarStyle];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self setBackButtonOnViewController:viewController];
    [super pushViewController:viewController animated:animated];
}

- (void)setBackButtonOnViewController:(UIViewController*)viewController {
    UIImage* defaultBackImage = [SenseStyle navigationBackImage];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithImage:defaultBackImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
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
