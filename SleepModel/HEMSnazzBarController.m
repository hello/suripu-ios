//
//  HEMSnazzBarController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSnazzBarController.h"
#import "HEMSnazzBar.h"
#import "HelloStyleKit.h"

@interface HEMSnazzBarController ()<HEMSnazzBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) HEMSnazzBar* buttonsBar;
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UISwipeGestureRecognizer* swipeToNextGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer* swipeToPreviousGestureRecognizer;
@end

@implementation HEMSnazzBarController

static CGFloat const HEMSnazzBarHeight = 66.f;
static CGFloat const HEMSnazzContentGestureMargin = 34.f;

- (void)dealloc
{
    _swipeToNextGestureRecognizer.delegate = nil;
    _swipeToPreviousGestureRecognizer.delegate = nil;
    _buttonsBar = nil;
    _contentView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureContainerViews];
    [self configureGestureRecognizers];
    [self reloadButtonsBar];
    [self showControllerAtIndex:self.selectedIndex animated:NO];
}

- (void)configureContainerViews
{
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.contentView];
    CGRect barFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), HEMSnazzBarHeight);
    self.buttonsBar = [[HEMSnazzBar alloc] initWithFrame:barFrame];
    self.buttonsBar.delegate = self;
    [self.view addSubview:self.buttonsBar];
    self.buttonsBar.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
    self.buttonsBar.selectionColor = [HelloStyleKit senseBlueColor];
    self.contentView.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
}

- (void)configureGestureRecognizers
{
    self.swipeToNextGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(didSwipe:)];
    self.swipeToNextGestureRecognizer.delegate = self;
    self.swipeToNextGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipeToPreviousGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(didSwipe:)];
    self.swipeToPreviousGestureRecognizer.delegate = self;
    self.swipeToPreviousGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
}

- (void)reloadButtonsBar
{
    [self.buttonsBar removeAllButtons];
    for (UIViewController* viewController in self.viewControllers) {
        [self.buttonsBar addButtonWithTitle:viewController.tabBarItem.title
                                      image:viewController.tabBarItem.image];
    }
    [self.buttonsBar selectButtonAtIndex:self.selectedIndex animated:NO];
}

- (void)hideBar:(BOOL)hidden animated:(BOOL)animated
{
    void (^animations)() = ^{
        [self showPartialBarWithRatio:hidden ? 0 : 1];
    };
    if (animated)
        [UIView animateWithDuration:HEMSnazzBarAnimationDuration animations:animations];
    else
        animations();
}

- (void)showPartialBarWithRatio:(CGFloat)ratio
{
    self.buttonsBar.alpha = ratio;
    CGFloat minX = -floorf(CGRectGetWidth(self.view.bounds)/3);
    CGRect frame = self.buttonsBar.frame;
    frame.origin.x = (1 - ratio) * minX;
    self.buttonsBar.frame = frame;
}

- (UIViewController *)selectedViewController
{
    if (self.selectedIndex != NSNotFound)
        return self.viewControllers[self.selectedIndex];
    return nil;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index >= self.viewControllers.count)
        return;

    BOOL shouldSelectIndex = YES;
    if ([self.delegate respondsToSelector:@selector(barController:shouldSelectIndex:)])
        shouldSelectIndex = [self.delegate barController:self shouldSelectIndex:index];
    if (!shouldSelectIndex)
        return;

    if ([self.delegate respondsToSelector:@selector(barController:willSelectIndex:)])
        [self.delegate barController:self willSelectIndex:index];

    if (index == _selectedIndex) {
        UIViewController* selectedController = self.selectedViewController;
        if ([selectedController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* navController = (id)selectedController;
            [navController popToRootViewControllerAnimated:animated];
        }
    } else if ([self isViewLoaded]) {
        [self showControllerAtIndex:index animated:animated];
    }

    _selectedIndex = index;
    if ([self.delegate respondsToSelector:@selector(barController:didSelectIndex:)])
        [self.delegate barController:self didSelectIndex:index];
}

- (void)showControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    UIViewController* fromController = self.selectedViewController;
    UIViewController* toController = self.viewControllers[index];

    [self hideBar:NO animated:animated];
    if (animated && fromController) {
        self.contentView.userInteractionEnabled = NO;
        [fromController.view removeGestureRecognizer:self.swipeToPreviousGestureRecognizer];
        [fromController.view removeGestureRecognizer:self.swipeToNextGestureRecognizer];
        CGRect toStartFrame = self.contentView.bounds;
        CGRect fromFinalFrame = self.contentView.bounds;
        CGFloat frameWidth = CGRectGetWidth(self.contentView.bounds);
        toStartFrame.origin.x = index > _selectedIndex ? frameWidth : -frameWidth;
        fromFinalFrame.origin.x = -toStartFrame.origin.x;
        toController.view.frame = toStartFrame;
        [self.contentView addSubview:toController.view];

        void (^completion)(BOOL) = ^(BOOL finished) {
            [fromController.view removeFromSuperview];
            self.contentView.userInteractionEnabled = YES;
            [toController.view addGestureRecognizer:self.swipeToNextGestureRecognizer];
            [toController.view addGestureRecognizer:self.swipeToPreviousGestureRecognizer];
        };
        void (^animations)() = ^{
            toController.view.frame = self.contentView.bounds;
            fromController.view.frame = fromFinalFrame;
        };

        [UIView animateWithDuration:HEMSnazzBarAnimationDuration
                         animations:animations completion:completion];
    } else {
        [fromController.view removeFromSuperview];
        [fromController.view removeGestureRecognizer:self.swipeToPreviousGestureRecognizer];
        [fromController.view removeGestureRecognizer:self.swipeToNextGestureRecognizer];
        toController.view.frame = self.contentView.bounds;
        [toController.view addGestureRecognizer:self.swipeToNextGestureRecognizer];
        [toController.view addGestureRecognizer:self.swipeToPreviousGestureRecognizer];
        [self.contentView addSubview:toController.view];
    }

    [self.buttonsBar selectButtonAtIndex:index animated:animated];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    for (UIViewController* controller in _viewControllers) {
        [controller willMoveToParentViewController:nil];
        [controller removeFromParentViewController];
    }

    _viewControllers = [viewControllers copy];

    for (UIViewController* controller in _viewControllers) {
        [self addChildViewController:controller];
        [controller didMoveToParentViewController:self];
    }

    if ([self isViewLoaded])
        [self reloadButtonsBar];
}

#pragma mark - HEMSnazzBarDelegate

- (void)bar:(HEMSnazzBar *)bar didReceiveTouchUpInsideAtIndex:(NSUInteger)index
{
    [self setSelectedIndex:index animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (void)didSwipe:(UISwipeGestureRecognizer*)recognizer
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.selectedIndex > 0)
            [self setSelectedIndex:self.selectedIndex - 1 animated:YES];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.selectedIndex < self.viewControllers.count - 1)
            [self setSelectedIndex:self.selectedIndex + 1 animated:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIViewController* controller = self.selectedViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (id)controller;
        if (![nav.topViewController isEqual:[nav.viewControllers firstObject]])
            return NO;
    }
    CGPoint location = [touch locationInView:self.contentView];
    return location.x > HEMSnazzContentGestureMargin
        && location.x < CGRectGetWidth(self.contentView.bounds) - HEMSnazzContentGestureMargin;
}

@end