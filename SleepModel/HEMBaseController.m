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
#import "HEMRootViewController.h"
#import "HEMPresenter.h"
#import "HEMBreadcrumbService.h"
#import "HEMAccountService.h"
#import "HEMSnazzBarController.h"

@interface HEMBaseController()

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

#pragma mark - View Controller Lifecycle Events

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [[self presenters] makeObjectsPerformSelector:@selector(didRelayout)];
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

- (UIViewController*)rootViewController {
    return [HEMRootViewController rootViewControllerForKeyWindow];
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
    [dialogVC setViewToShowThrough:seeThroughView];
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

- (void)reloadTopBar {
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    HEMSnazzBarController* snazzVC = [rootVC barController];
    [snazzVC reloadButtonsBarBadges];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_shadowView) {
        [_shadowView removeFromSuperview];
    }
}

@end
