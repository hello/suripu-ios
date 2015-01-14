//
//  HEMSettingsNavigationController.m
//  Sense
//
//  Created by Jimmy Lu on 9/25/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMSettingsNavigationController.h"
#import "HEMRootViewController.h"
#import "HEMAppDelegate.h"
#import "HelloStyleKit.h"

@interface HEMSettingsNavigationController()

@property (nonatomic, assign) UIStatusBarStyle previousBarStyle;

@end

@implementation HEMSettingsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[HelloStyleKit backViewBackgroundColor]];
    
    [self configureNavigationBar];
    
    [self.interactivePopGestureRecognizer addTarget:self
                                             action:@selector(interactivePopGestureActivated:)];
}

- (void)configureNavigationBar {
    [[self navigationBar] setBarTintColor:[HelloStyleKit backViewTintColor]];
    [[self navigationBar] setTranslucent:NO];
    [[self navigationBar] setClipsToBounds:NO];
    [[self navigationBar] setShadowImage:nil];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.interactivePopGestureRecognizer.enabled = NO;
    [[viewController view] setBackgroundColor:[HelloStyleKit backViewBackgroundColor]];
    [super pushViewController:viewController animated:animated];
    [self updateTopBarVisibilityAnimated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController* controller = [super popViewControllerAnimated:animated];
    [self updateTopBarVisibilityAnimated:animated];
    return controller;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray* controllers = [super popToRootViewControllerAnimated:animated];
    [self updateTopBarVisibilityAnimated:animated];
    return controllers;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray* controllers = [super popToViewController:viewController animated:animated];
    [self updateTopBarVisibilityAnimated:animated];
    return controllers;
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if ([context isCancelled]) {
            [self hideTopBarAnimated:animated];
        } else {
            [self updateTopBarVisibilityAnimated:animated];
        }
    }];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    self.interactivePopGestureRecognizer.enabled = ![viewController isEqual:[self.viewControllers firstObject]];
}

#pragma mark - Top Bar Handling

- (void)updateBarVisibilityWithRatio:(CGFloat)ratio {
    HEMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
    HEMRootViewController* root = (id)delegate.window.rootViewController;
    [root showPartialSettingsDrawerTopBarWithRatio:ratio];
}

- (void)updateTopBarVisibilityAnimated:(BOOL)animated {
    if ([self.topViewController isEqual:[self.viewControllers firstObject]])
        [self showTopBarAnimated:animated];
    else
        [self hideTopBarAnimated:animated];
}

- (void)hideTopBarAnimated:(BOOL)animated {
    HEMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
    HEMRootViewController* root = (id)delegate.window.rootViewController;
    [root hideSettingsDrawerTopBar:YES animated:animated];
}

- (void)showTopBarAnimated:(BOOL)animated {
    HEMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
    HEMRootViewController* root = (id)delegate.window.rootViewController;
    [root hideSettingsDrawerTopBar:NO animated:animated];
}

#pragma mark - Gesture Recognizer

- (void)interactivePopGestureActivated:(UIGestureRecognizer*)recognizer {
    CGFloat ratio = [recognizer locationInView:self.view].x/CGRectGetWidth(self.view.bounds);
    if (recognizer.state == UIGestureRecognizerStateChanged && self.viewControllers.count < 2) {
        [self updateBarVisibilityWithRatio:ratio];
    }
}

@end
