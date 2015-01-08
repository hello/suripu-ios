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

@interface HEMStyledNavigationViewController ()

@end

@implementation HEMStyledNavigationViewController

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
    [self setBackButtonOnViewController:viewController];
    [[viewController view] setBackgroundColor:[HelloStyleKit backViewBackgroundColor]];
    [super pushViewController:viewController animated:animated];
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
