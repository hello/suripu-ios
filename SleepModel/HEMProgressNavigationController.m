//
//  HEMProgressNavigationController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "HEMProgressNavigationController.h"
#import "HelloStyleKit.h"

@interface HEMProgressNavigationController()

@property (strong, nonatomic) UIProgressView* progressView;
@property (strong, nonatomic) UIImageView* bgImageView;
@property (assign, nonatomic) NSInteger currentScreenCount;

@end

@implementation HEMProgressNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCurrentScreenCount:0];
    [self setupProgressBar];
}

- (void)setupProgressBar {
    CGRect bounds = [[self view] bounds];
    CGRect progressFrame = CGRectZero;
    progressFrame.size.height = 2.0f;
    progressFrame.origin.y = CGRectGetHeight(bounds) - CGRectGetHeight(progressFrame);
    progressFrame.size.width = CGRectGetWidth(bounds);
    
    [self setProgressView:[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar]];
    [[self progressView] setFrame:progressFrame];
    [[self progressView] setTintColor:[HelloStyleKit mediumBlueColor]];
    [[self progressView] setProgress:0.0f];
    [[self view] addSubview:[self progressView]];
}

- (void)setBgImage:(UIImage *)bgImage {
    _bgImage = bgImage;
    if (bgImage != nil && [self bgImageView] == nil) {
        UIImageView* bgImageView = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
        [bgImageView setImage:[self bgImage]];
        [[self view] insertSubview:bgImageView atIndex:0];
        [self setBgImageView:bgImageView];
    }
    [[self bgImageView] setImage:bgImage];
}

- (void)updateProgress:(BOOL)animated {
    if ([self numberOfScreens] < 2) return;
    
    if (![[self progressView] isHidden] && [self numberOfScreens] > 0) {
        [[self progressView] setProgress:[self currentScreenCount]/(float)[self numberOfScreens]
                                animated:animated];
        [[self view] addSubview:[self progressView]];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    [self setCurrentScreenCount:[self currentScreenCount]+1];
    [self updateProgress:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController* controller = [super popViewControllerAnimated:animated];
    [self setCurrentScreenCount:[self currentScreenCount]-1];
    [self updateProgress:animated];
    return controller;
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray* controllers = [super popToRootViewControllerAnimated:animated];
    [self setCurrentScreenCount:1];
    [self updateProgress:animated];
    return controllers;
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray* controllers = [super popToViewController:viewController animated:animated];
    [self setCurrentScreenCount:[self currentScreenCount] - [controllers count]];
    [self updateProgress:animated];
    return controllers;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    [super setViewControllers:viewControllers];
    [self setCurrentScreenCount:[self currentScreenCount] + [viewControllers count]];
    [self updateProgress:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    [self setCurrentScreenCount:[self currentScreenCount] + [viewControllers count]];
    [self updateProgress:animated];
}

@end
