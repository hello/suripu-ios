//
//  HEMStyledNavigationViewController.m
//  Sense
//
//  Created by Delisa Mason on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMStyledNavigationViewController.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

@interface HEMStyledNavigationViewController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation HEMStyledNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationBar] setTintColor:[HelloStyleKit backViewTintColor]];
    [[self navigationBar] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [HelloStyleKit backViewNavTitleColor],
        NSFontAttributeName : [UIFont settingsTitleFont]
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

@end
