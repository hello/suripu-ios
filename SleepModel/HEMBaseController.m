//
//  HEMBaseController.m
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"
#import "HEMAlertViewController.h"
#import "HEMSupportUtil.h"
#import "HEMScreenUtils.h"
#import "HEMPresenter.h"
#import "HEMBreadcrumbService.h"
#import "HEMAccountService.h"

#import "Sense-Swift.h"

@interface HEMBaseController() <Themed>

@property (nonatomic, strong) HEMNavigationShadowView* shadowView;
@property (nonatomic, assign) BOOL adjustedConstraints;
@property (nullable, nonatomic, strong) NSArray<HEMPresenter*>* presenters;

@end

@implementation HEMBaseController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self listenForAccountEvents];
    }
    return self;
}

- (UIViewController*)rootViewController {
    return [RootViewController currentRootViewController];
}
    
- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[SenseStyle theme] statusBarStyle];
}

#pragma mark - Themed

- (void)didChangeWithTheme:(Theme *)theme auto:(BOOL)auto_ {
    [self setNeedsStatusBarAppearanceUpdate];
    for (HEMPresenter* presenter in [self presenters]) {
        [presenter didChangeTheme:theme auto:auto_];
    }
}

#pragma mark - View Controller Lifecycle Events

- (void)viewDidLoad {
    [super viewDidLoad];
    [self applyStyle];
    [self listenForAppEvents];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self shadowView] setHidden:NO];
    [[self presenters] makeObjectsPerformSelector:@selector(willAppear)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self presenters] makeObjectsPerformSelector:@selector(didAppear)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self shadowView] setHidden:YES];
    [[self presenters] makeObjectsPerformSelector:@selector(willDisappear)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self presenters] makeObjectsPerformSelector:@selector(didDisappear)];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [[self presenters] makeObjectsPerformSelector:@selector(willRelayout)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [[self presenters] makeObjectsPerformSelector:@selector(didRelayout)];
    for (HEMPresenter* presenter in [self presenters]) {
        if (![presenter shadowView]) {
            [presenter bindWithShadowView:[self shadowView]];
        }
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (parent) {
        [[self presenters] makeObjectsPerformSelector:@selector(didMoveToParent)];
    } else {
        [[self presenters] makeObjectsPerformSelector:@selector(wasRemovedFromParent)];
    }
}

#pragma mark - Account Events

- (void)listenForAccountEvents {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didRefreshAccount)
                   name:HEMAccountServiceNotificationDidRefresh
                 object:nil];
}

- (void)didRefreshAccount {}

#pragma mark - App Events

- (void)listenForAppEvents {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(viewDidBecomeActive)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(viewDidEnterBackground)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
}

- (void)viewDidBecomeActive {
    [[self presenters] makeObjectsPerformSelector:@selector(didComeBackFromBackground)];
}

- (void)viewDidEnterBackground {
    [[self presenters] makeObjectsPerformSelector:@selector(didEnterBackground)];
}

#pragma mark - Shadows

- (BOOL)wantsShadowView {
    return YES;
}

- (HEMNavigationShadowView*)shadowView {
    if (!_shadowView && [self wantsShadowView]) {
        [self setExtendedLayoutIncludesOpaqueBars:NO];
        UINavigationBar* navBar = [[self navigationController] navigationBar];
        if (navBar) {
            _shadowView = [[HEMNavigationShadowView alloc] initWithNavigationBar:navBar];
            [navBar addSubview:_shadowView];
        }
    }
    return _shadowView;
}

#pragma mark - Presenters

- (void)addPresenter:(HEMPresenter*)presenter {
    NSMutableArray* mutableList = nil;
    if ([self presenters]) {
        mutableList = [[self presenters] mutableCopy];
    } else {
        mutableList = [NSMutableArray array];
    }
    [mutableList addObject:presenter];
    [self setPresenters:mutableList];
}

#pragma mark - Constraints / Layouts for Devices

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (![self adjustedConstraints]) {
        if (HEMIsIPhone4Family()) {
            [self adjustConstraintsForIPhone4];
        } else if (HEMIsIPhone5Family()) {
            [self adjustConstraintsForIphone5];
        }
        [self setAdjustedConstraints:YES];
    }
}

- (void)adjustConstraintsForIphone5 { /* do nothing here, meant for subclasses */ }

- (void)adjustConstraintsForIPhone4 { /* do nothing here, meant for subclasses */ }

- (void)updateConstraint:(NSLayoutConstraint*)constraint withDiff:(CGFloat)diff {
    CGFloat constant = [constraint constant];
    [constraint setConstant:constant + diff];
}

#pragma mark - Convenience

- (BOOL)isFullyVisibleInWindow {
    UIWindow* window = [[[UIApplication sharedApplication] windows] firstObject];
    CGRect windowFrame = [window frame];
    CGRect myViewFrame = [[self view] convertRect:[[self view] bounds] toView:window];
    return CGRectContainsRect(windowFrame, myViewFrame);
}

- (void)dismissModalAfterDelay:(BOOL)delay {
    // dismiss modal view controller does not call controller appearance methods
    // so we need to do it ourselves, to trigger the childs to handle changes
    __weak typeof(self) weakSelf = self;
    void(^done)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIViewController* child = [[strongSelf childViewControllers] firstObject];
        [child beginAppearanceTransition:YES animated:YES];
        [child endAppearanceTransition];
    };
    
    if (delay) {
        NSTimeInterval delayInSeconds = 1.5f;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
            [self dismissViewControllerAnimated:YES completion:done];
        });
    } else {
        [self dismissViewControllerAnimated:YES completion:done];
    }
}

#pragma mark - Main tabs

- (void)switchMainTab:(NSInteger)tab {
    UIViewController* controller = [RootViewController currentRootViewController];
    if ([controller isKindOfClass:[RootViewController class]]) {
        RootViewController* rootVC = (id) controller;
        MainViewController* mainVC = [rootVC mainViewController];
        [mainVC switchTabWithTab:tab];
    }
}

#pragma mark - alerts

- (UIView*)backgroundViewForAlerts {
    UIView* bgView = nil;
    if ([self parentViewController]) {
        bgView = [[self parentViewController] view];
    } else if ([self navigationController]) {
        bgView = [[self navigationController] view];
    } else {
        bgView = [self view];
    }
    return bgView;
}

- (void)showMessageDialog:(NSString*)message title:(NSString*)title {
    [self showMessageDialog:message
                      title:title
                      image:nil
             seeThroughView:[self backgroundViewForAlerts]
               withHelpPage:nil];
}

- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                    image:(UIImage*)image
             withHelpPage:(NSString*)helpPage {
    [self showMessageDialog:message
                      title:title
                      image:image
             seeThroughView:[self backgroundViewForAlerts]
               withHelpPage:helpPage];
}

- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                    image:(UIImage*)image
           seeThroughView:(UIView*)seeThroughView
             withHelpPage:(NSString*)helpPage {
    
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC setDialogImage:image];
    __weak typeof(self) weakSelf = self;
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.ok", nil) style:HEMAlertViewButtonStyleRoundRect action:nil];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"dialog.help.title", nil)
                           style:HEMAlertViewButtonStyleBlueText
                          action:^{
            [HEMSupportUtil openHelpToPage:helpPage fromController:weakSelf];
        }];
    [dialogVC showFrom:self];
}

- (BOOL)showIndicatorForCrumb:(NSString*)crumb {
    SENAccount* account = [[HEMAccountService sharedService] account]; // if not ready, will return NO
    HEMBreadcrumbService* service = [HEMBreadcrumbService sharedServiceForAccount:account];
    NSString* topCrumb = [service peek];
    return [topCrumb isEqualToString:crumb];
}

- (void)clearCrumb:(NSString*)crumb {
    SENAccount* account = [[HEMAccountService sharedService] account]; // if not ready, will return NO
    HEMBreadcrumbService* service = [HEMBreadcrumbService sharedServiceForAccount:account];
    NSString* peek = [service peek];
    if ([peek isEqualToString:crumb]) {
        [service pop];
    } else {
        [self clearCrumbTrailIfEndsAt:crumb];
    }
}

- (void)clearCrumbTrailIfEndsAt:(NSString*)crumb {
    SENAccount* account = [[HEMAccountService sharedService] account]; // if not ready, will return NO
    HEMBreadcrumbService* service = [HEMBreadcrumbService sharedServiceForAccount:account];
    [service clearIfTrailEndsAt:crumb];
}
#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_shadowView) {
        [_shadowView removeFromSuperview];
    }
}

@end
