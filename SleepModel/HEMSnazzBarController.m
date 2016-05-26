//
//  HEMSnazzBarController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSnazzBarController.h"
#import "HEMSnazzBar.h"
#import "UIColor+HEMStyle.h"

CGFloat const HEMSnazzBarHeight = 64.0f;

@interface HEMSnazzBarController ()<HEMSnazzBarDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) HEMSnazzBar* buttonsBar;
@property (nonatomic, strong) NSMutableArray* controllerVisibility;
@property (nonatomic, strong) UIScrollView* contentView;
@property (nonatomic, assign) CGFloat previousScrollOffsetX;
@property (nonatomic, assign) NSInteger previousSelectedIndex;
@property (nonatomic, assign, getter=isUserScrolling) BOOL userScrolling;
@end

@implementation HEMSnazzBarController

- (void)dealloc {
    _buttonsBar = nil;
    _contentView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureContainerViews];
    [self reloadButtonsBar];
    [self showControllerAtIndex:self.selectedIndex animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self notifyControllerAppearanceAtIndexIfNeeded:self.selectedIndex];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self notifyControllerAppearanceAtIndexIfNeeded:self.selectedIndex];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)configureContainerViews {
    self.contentView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.contentView.pagingEnabled = YES;
    self.contentView.showsHorizontalScrollIndicator = NO;
    self.contentView.showsVerticalScrollIndicator = NO;
    self.contentView.backgroundColor = [UIColor backgroundColor];
    self.contentView.delegate = self;
    
    [self updateContentSize];
    [self.view addSubview:self.contentView];
    
    CGRect barFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), HEMSnazzBarHeight);
    self.buttonsBar = [[HEMSnazzBar alloc] initWithFrame:barFrame];
    self.buttonsBar.delegate = self;
    self.buttonsBar.backgroundColor = [UIColor whiteColor];
    self.buttonsBar.selectionColor = [UIColor tintColor];
    
    [self.view addSubview:self.buttonsBar];
}

- (void)updateContentSize {
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGSize contentSize = self.contentView.contentSize;
    contentSize.width = viewWidth * self.viewControllers.count;
    self.contentView.contentSize = contentSize;
}

#pragma mark - SnazzBar

- (void)reloadButtonsBarBadges {
    NSUInteger index = 0;
    for (UIViewController* viewController in self.viewControllers) {
        [self.buttonsBar showUnreadIndicator:viewController.tabBarItem.badgeValue != nil
                                     atIndex:index];
        
        index++;
    }
}

- (void)reloadButtonsBar {
    [self.buttonsBar removeAllButtons];
    
    NSUInteger index = 0;
    for (UIViewController* viewController in self.viewControllers) {
        [self.buttonsBar addButtonWithTitle:viewController.tabBarItem.title
                                      image:viewController.tabBarItem.image
                              selectedImage:viewController.tabBarItem.selectedImage];
        
        [self.buttonsBar showUnreadIndicator:viewController.tabBarItem.badgeValue != nil
                                     atIndex:index];
        
        index++;
    }
    
    [self.buttonsBar selectButtonAtIndex:self.selectedIndex animated:NO];
}

- (void)hideBar:(BOOL)hidden animated:(BOOL)animated {
    void (^animations)() = ^{
        [self showPartialBarWithRatio:hidden ? 0 : 1];
    };
    if (animated)
        [UIView animateWithDuration:HEMSnazzBarAnimationDuration animations:animations];
    else
        animations();
    
    self.contentView.scrollEnabled = !hidden;
}

- (void)showPartialBarWithRatio:(CGFloat)ratio {
    self.buttonsBar.alpha = ratio;
    CGFloat minX = -floorf(CGRectGetWidth(self.view.bounds)/3);
    CGRect frame = self.buttonsBar.frame;
    frame.origin.x = (1 - ratio) * minX;
    self.buttonsBar.backgroundColor = [UIColor colorWithWhite:1 alpha:ratio];
    self.buttonsBar.frame = frame;
}

#pragma mark HEMSnazzBarDelegate

- (void)bar:(HEMSnazzBar *)bar didReceiveTouchUpInsideAtIndex:(NSUInteger)index {
    [self setSelectedIndex:index animated:YES];
    [self notifySelectedControllerOfSelectionChangeIfSupported];
    [SENAnalytics track:HEMAnalyticsEventBackViewTapped];
}

#pragma mark - Controller Management

- (void)loadControllerViewAtIndexIfNeeded:(NSInteger)index {
    if (index < 0 || index >= self.viewControllers.count) {
        return;
    }
    
    UIViewController* toController = self.viewControllers[index];
    if (toController.view.superview != self.contentView) {
        CGFloat offsetX = index * CGRectGetWidth(self.contentView.bounds);
        CGRect frame = toController.view.frame;
        frame.origin = CGPointMake(offsetX, 0.0f);
        frame.size = self.contentView.bounds.size;
        toController.view.frame = frame;
        [self.contentView insertSubview:toController.view atIndex:index];
    }

}

- (void)notifyControllerAppearanceAtIndexIfNeeded:(NSInteger)index {
    if (index < 0 || index >= self.viewControllers.count) {
        return;
    }
    
    UIViewController* controller = self.viewControllers[index];
    NSNumber* visibility = self.controllerVisibility[index];
    BOOL visibleNow = CGRectIntersectsRect(self.contentView.bounds, controller.view.frame);
    if ([visibility boolValue] != visibleNow) {
        [controller beginAppearanceTransition:visibleNow animated:NO];
        [controller endAppearanceTransition];
        self.controllerVisibility[index] = @(visibleNow);
        
        if (!visibleNow) {
            [self.buttonsBar showUnreadIndicator:controller.tabBarItem.badgeValue != nil
                                         atIndex:index];
        }
    }
}

- (UIViewController *)selectedViewController {
    if (self.selectedIndex != NSNotFound)
        return self.viewControllers[self.selectedIndex];
    return nil;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated {
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
    
    _previousSelectedIndex = _selectedIndex;
    _selectedIndex = index;
    if ([self.delegate respondsToSelector:@selector(barController:didSelectIndex:)])
        [self.delegate barController:self didSelectIndex:index];
}

- (void)showControllerAtIndex:(NSUInteger)index animated:(BOOL)animated {
    [self hideBar:NO animated:animated];
    [self loadControllerViewAtIndexIfNeeded:index];
    [self.buttonsBar selectButtonAtIndex:index animated:animated];
    
    CGFloat offsetX = index * CGRectGetWidth(self.contentView.bounds);
    if (offsetX != self.contentView.contentOffset.x) {
        [self.contentView setContentOffset:CGPointMake(offsetX, 0.0f) animated:animated];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
    for (UIViewController* controller in _viewControllers) {
        [controller willMoveToParentViewController:nil];
        [controller removeFromParentViewController];
    }

    NSMutableArray* visibilities = [NSMutableArray arrayWithCapacity:[viewControllers count]];
    _viewControllers = [viewControllers copy];

    for (UIViewController* controller in _viewControllers) {
        [self addChildViewController:controller];
        [controller didMoveToParentViewController:self];
        [visibilities addObject:@NO];
    }
    
    [self setControllerVisibility:visibilities];

    if ([self isViewLoaded])
        [self reloadButtonsBar];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self setUserScrolling:YES];
    [self notifySelectedControllerOfSelectionChangeIfSupported];
    [SENAnalytics track:HEMAnalyticsEventBackViewSwipe];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffsetX = scrollView.contentOffset.x;
    CGFloat contentWidth = CGRectGetWidth(self.contentView.bounds);
    NSInteger targetIndex = scrollOffsetX / contentWidth;
    NSInteger previousIndex = self.previousScrollOffsetX / contentWidth;
    CGFloat percentageScrolled = scrollOffsetX / (contentWidth * [[self viewControllers] count]);
    
    if ([self isUserScrolling]) {
        // only animate the snazzbar separately on scroll if it was user actively
        // scrolling and not from a button press
        [[self buttonsBar] setSelectionRatio:percentageScrolled];
    }
    
    [self loadControllerViewAtIndexIfNeeded:targetIndex];
    [self notifyControllerAppearanceAtIndexIfNeeded:targetIndex];
    [self notifyControllerAppearanceAtIndexIfNeeded:previousIndex];
    
    self.previousScrollOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger targetIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    [self notifyControllerAppearanceAtIndexIfNeeded:self.selectedIndex];
    [self setUserScrolling:NO];
    [self setSelectedIndex:targetIndex];
    [self notifySelectedControllerOfSelectionIfSupported];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self notifyControllerAppearanceAtIndexIfNeeded:self.previousSelectedIndex];
    [self notifySelectedControllerOfSelectionIfSupported];
}

#pragma mark - Snazz Child Handling

- (id<HEMSnazzBarControllerChild>)selectedSnazzChild {
    UIViewController* selectedVC = [self selectedViewController];
    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
        selectedVC = [[(UINavigationController*)selectedVC viewControllers] firstObject];
    }
    
    if ([selectedVC conformsToProtocol:@protocol(HEMSnazzBarControllerChild)]) {
        return (id<HEMSnazzBarControllerChild>)selectedVC;
    }
    
    return nil;
}

- (void)notifySelectedControllerOfSelectionIfSupported {
    id<HEMSnazzBarControllerChild> snazzChild = [self selectedSnazzChild];
    if ([snazzChild respondsToSelector:@selector(snazzViewDidAppear)]) {
        [snazzChild snazzViewDidAppear];
    }
}

- (void)notifySelectedControllerOfSelectionChangeIfSupported {
    id<HEMSnazzBarControllerChild> snazzChild = [self selectedSnazzChild];
    if ([snazzChild respondsToSelector:@selector(snazzViewDidAppear)]) {
        [snazzChild snazzViewDidAppear];
    }
}

@end
