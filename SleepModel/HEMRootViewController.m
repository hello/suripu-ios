//
//  HEMRootViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceDevice.h>

#import "NSDate+HEMRelative.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "UIView+HEMMotionEffects.h"
#import "UIColor+HEMStyle.h"

#import "HEMRootViewController.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HEMSnazzBarController.h"
#import "HEMMainStoryboard.h"
#import "HEMDebugController.h"
#import "HEMSleepGraphViewController.h"
#import "HEMDynamicsStatusStyler.h"
#import "HEMAppDelegate.h"
#import "HEMConfig.h"
#import "HEMTimelineContainerViewController.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingController.h"
#import "HEMAppUsage.h"
#import "HEMScreenUtils.h"
#import "UIView+HEMSnapshot.h"
#import "HEMDynamicsShadowStyler.h"

#import "HEMSystemAlertPresenter.h"
#import "HEMDeviceAlertService.h"
#import "HEMNetworkAlertService.h"
#import "HEMSupportUtil.h"
#import "HEMTimeZoneViewController.h"
#import "HEMTimeZoneAlertService.h"
#import "HEMSimpleModalTransitionDelegate.h"
#import "HEMSoundsContainerViewController.h"
#import "HEMShortcutService.h"
#import "HEMDeviceService.h"

NSString* const HEMRootDrawerMayOpenNotification = @"HEMRootDrawerMayOpenNotification";
NSString* const HEMRootDrawerMayCloseNotification = @"HEMRootDrawerMayCloseNotification";
NSString* const HEMRootDrawerDidOpenNotification = @"HEMRootDrawerDidOpenNotification";
NSString* const HEMRootDrawerDidCloseNotification = @"HEMRootDrawerDidCloseNotification";

@interface HEMRootViewController () <MSDynamicsDrawerViewControllerDelegate, UIPageViewControllerDelegate, HEMSystemAlertDelegate>

@property (strong, nonatomic) HEMDebugController* debugController;
@property (strong, nonatomic) MSDynamicsDrawerViewController* drawerViewController;
@property (assign, nonatomic, getter=isMainControllerLoaded) BOOL mainControllerLoaded;
@property (nonatomic, getter=isAnimatingPaneState) BOOL animatingPaneState;

@property (nonatomic, weak)   HEMSystemAlertPresenter* systemAlertPresenter;
@property (nonatomic, strong) HEMDeviceAlertService* deviceAlertService;
@property (nonatomic, strong) HEMTimeZoneAlertService* tzAlertService;
@property (nonatomic, strong) HEMNetworkAlertService* networkAlertService;
@property (nonatomic, strong) HEMDeviceService* deviceService;

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> tzViewControllerTransition;

@end

@implementation HEMRootViewController

CGFloat const HEMRootDrawerDefaultGravityMagnitude = 2.5;
CGFloat const HEMRootDrawerAnimationGravityMagnitude = 1.f;
static CGFloat const HEMRootDrawerRevealHeight = 56.f;
static CGFloat const HEMRootDrawerStatusBarOffset = 20.f;

+ (instancetype)rootViewControllerForKeyWindow
{
    HEMAppDelegate* delegate = (id)[UIApplication sharedApplication].delegate;
    return (id)delegate.window.rootViewController;
}

+ (UIViewController*)instantiateDrawerViewController
{
    HEMSnazzBarController* barController = [HEMSnazzBarController new];
    barController.viewControllers = @[
        [HEMMainStoryboard instantiateCurrentNavController],
        [HEMMainStoryboard instantiateTrendsViewController],
        [HEMMainStoryboard instantiateInsightFeedViewController],
        [HEMMainStoryboard instantiateSoundsNavigationViewController],
        [HEMMainStoryboard instantiateSettingsNavController]
    ];
    barController.selectedIndex = 2;
    return barController;
}

/**
 *  Creates a new pane controller. If `startDate` is nil, defaults to the
 *  previous day.
 *
 *  @param startDate the presented date of the controller. May be nil.
 *
 *  @return a new pane controller
 */
- (UIViewController*)instantiatePaneViewControllerWithDate:(NSDate*)startDate
{
    if (!startDate)
        startDate = [NSDate timelineInitialDate];
    
    HEMSleepSummarySlideViewController* slideController = [[HEMSleepSummarySlideViewController alloc] initWithDate:startDate];
    [slideController setDelegate:self];

    HEMTimelineContainerViewController* container = [HEMMainStoryboard instantiateTimelineContainerController];
    [container setTimelineController:slideController];

    return container;
}

- (void)viewDidBecomeActive
{
    [super viewDidBecomeActive];
    [[self systemAlertPresenter] setEnable:[self shouldMonitorSystem]];
    
    [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageAppLaunched];
    [SENAnalytics track:kHEMAnalyticsEventAppLaunched];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureSystemAlerts];
    [self registerForNotifications];

    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    if ([service hasFinishedOnboarding]) {
        [self showArea:HEMRootAreaTimeline animated:NO];
        [self setMainControllerLoaded:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // if controller has not been loaded yet in viewDidLoad, check and see if we
    // need to launch the onboarding controller.  Onboarding currently is presented
    // modally, which can't be loaded in viewDidLoad.
    if (![self isMainControllerLoaded]) {
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        if (![service hasFinishedOnboarding]) {
            [self showArea:HEMRootAreaOnboarding animated:NO];
            [self setMainControllerLoaded:YES];
        }
    }
}

- (BOOL)accessibilityPerformMagicTap {
    [self toggleSettingsDrawer];
    return YES;
}

- (void)viewDidEnterBackground
{
    [super viewDidEnterBackground];
    [SENAnalytics track:kHEMAnalyticsEventAppClosed];
}

#pragma mark - 3D Touch Notifications

- (void)reactToShortcut:(NSNotification*)note {
    NSNumber* action = [note userInfo][HEMShortcutNoteInfoAction];
    switch ([action unsignedIntegerValue]) {
        case HEMShortcutActionAlarmNew:
        case HEMShortcutActionAlarmEdit:
            [self showSettingsDrawerTabAtIndex:HEMRootDrawerTabSounds animated:YES];
            break;
        default:
            break;
    }
}

#pragma mark - System Alerts

- (void)configureSystemAlerts {
    HEMDeviceAlertService* deviceAlertService = [HEMDeviceAlertService new];
    HEMNetworkAlertService*  networkAlertService = [HEMNetworkAlertService new];
    HEMTimeZoneAlertService* tzAlertService = [HEMTimeZoneAlertService new];
    HEMDeviceService* deviceService = [HEMDeviceService new];
    
    HEMSystemAlertPresenter* sysAlertPresenter
    = [[HEMSystemAlertPresenter alloc] initWithNetworkAlertService:networkAlertService
                                                deviceAlertService:deviceAlertService
                                              timeZoneAlertService:tzAlertService
                                                     deviceService:deviceService];
    
    [sysAlertPresenter setDelegate:self];
    [sysAlertPresenter bindWithContainerView:[self view]];
    
    [self setNetworkAlertService:networkAlertService];
    [self setDeviceAlertService:deviceAlertService];
    [self setTzAlertService:tzAlertService];
    [self setSystemAlertPresenter:sysAlertPresenter];
    [self setDeviceService:deviceService];
    
    [self addPresenter:sysAlertPresenter];
}

- (void)presentSupportPageWithSlug:(NSString *)supportPageSlug from:(HEMSystemAlertPresenter *)presenter {
    [HEMSupportUtil openHelpToPage:supportPageSlug fromController:self];
}

- (void)presentViewController:(UIViewController *)controller from:(HEMSystemAlertPresenter *)presenter {
    if ([controller isKindOfClass:[HEMTimeZoneViewController class]]) {
        HEMSimpleModalTransitionDelegate* transition = [HEMSimpleModalTransitionDelegate new];
        [transition setWantsStatusBar:YES];
        [self setTzViewControllerTransition:transition]; // must hold a ref to it since controller ref is weak
        [controller setTransitioningDelegate:[self tzViewControllerTransition]];
        [controller setModalPresentationStyle:UIModalPresentationCustom];
    }
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)dismissCurrentViewControllerFrom:(HEMSystemAlertPresenter *)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (UIWindow*)keyWindow
{
    return [UIApplication sharedApplication].keyWindow ?: [[[UIApplication sharedApplication] windows] firstObject];
}

- (BOOL)isStatusBarHidden {
    UIWindow* window = [self keyWindow];
    return window.windowLevel == UIWindowLevelStatusBar + 1;
}

- (void)hideStatusBar
{
    UIWindow* window = [self keyWindow];
    window.windowLevel = UIWindowLevelStatusBar + 1;
}

- (void)showStatusBar
{
    UIWindow* window = [self keyWindow];
    window.windowLevel = UIWindowLevelNormal;
}

- (UIViewController*)backController
{
    return [self.drawerViewController drawerViewControllerForDirection:MSDynamicsDrawerDirectionTop];
}

- (UIViewController*)frontController
{
    return self.drawerViewController.paneViewController;
}

- (BOOL)drawerIsVisible
{
    return self.drawerViewController.paneState != MSDynamicsDrawerPaneStateClosed;
}

- (BOOL)createDrawerViewController
{
    if (self.drawerViewController != nil) {
        return NO;
    }

    self.drawerViewController = [MSDynamicsDrawerViewController new];
    self.drawerViewController.paneViewController = [self instantiatePaneViewControllerWithDate:nil];
    self.drawerViewController.delegate = self;
    self.drawerViewController.gravityMagnitude = HEMRootDrawerDefaultGravityMagnitude;
    [self hideStatusBar];
    
    [self.drawerViewController addStylersFromArray:@[ [HEMDynamicsStatusStyler styler], [HEMDynamicsShadowStyler styler]]
                                      forDirection:MSDynamicsDrawerDirectionTop];
    [self.drawerViewController setDrawerViewController:[HEMRootViewController instantiateDrawerViewController]
                                          forDirection:MSDynamicsDrawerDirectionTop];
    
    [self adjustRevealHeight];
    [self.drawerViewController setShouldAlignStatusBarToPaneView:NO];

    [self.drawerViewController willMoveToParentViewController:nil];
    [self.drawerViewController removeFromParentViewController];
    [self.view addSubview:self.drawerViewController.view];
    [self addChildViewController:self.drawerViewController];
    [self.drawerViewController didMoveToParentViewController:self];

    return YES;
}

- (void)removeDrawerViewController
{
    if ([self drawerViewController] != nil) {
        [[self drawerViewController] willMoveToParentViewController:nil];
        [[self drawerViewController] removeFromParentViewController]; // calls didMoveToParentViewController:nil
        [[[self drawerViewController] view] removeFromSuperview];
        [self setDrawerViewController:nil];
    }
}

- (CGFloat)drawerPaneRevealHeight {
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGRect windowFrame = HEMKeyWindowBounds();
    CGFloat statusBarHeight = MIN(CGRectGetHeight(statusBarFrame), CGRectGetWidth(statusBarFrame));
    CGFloat screenHeight = MAX(CGRectGetHeight(windowFrame), CGRectGetWidth(windowFrame));
    return screenHeight - (HEMRootDrawerRevealHeight + statusBarHeight - HEMRootDrawerStatusBarOffset);
}

- (void)adjustRevealHeight
{
    MSDynamicsDrawerPaneState state = self.drawerViewController.paneState;
    self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
    [self.drawerViewController setRevealWidth:[self drawerPaneRevealHeight] forDirection:MSDynamicsDrawerDirectionTop];
    self.drawerViewController.paneState = state;
    self.drawerViewController.view.frame = HEMKeyWindowBounds();
}

- (void)registerForNotifications
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didAuthorize)
                   name:SENAuthorizationServiceDidAuthorizeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(adjustRevealHeight)
                   name:UIApplicationDidChangeStatusBarFrameNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(didFinishOnboarding)
                   name:HEMOnboardingNotificationComplete
                 object:nil];
    [center addObserver:self
               selector:@selector(showOnboarding)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(reactToShortcut:)
                   name:nil
                 object:[HEMShortcutService sharedService]];
}

- (BOOL)shouldMonitorSystem {
    return [SENAuthorizationService isAuthorized]
        && [self presentedViewController] == nil
        && [[HEMOnboardingService sharedService] hasFinishedOnboarding];
}

- (void)reloadTimelineSlideViewControllerWithDate:(NSDate*)date
{
    UIViewController* controller = [self instantiatePaneViewControllerWithDate:date];
    [self.drawerViewController setPaneViewController:controller
                                            animated:NO
                                          completion:NULL];
}

#pragma mark - Handling different state of the app

- (void)showArea:(HEMRootArea)area animated:(BOOL)animated
{
    switch (area) {
    case HEMRootAreaOnboarding:
        [self launchOnboarding:animated];
        break;
    case HEMRootAreaTimeline:
        [self launchDrawerControllerAnimated:animated intoSettings:NO];
        break;
    case HEMRootAreaBackView:
        [self launchDrawerControllerAnimated:animated intoSettings:YES];
        break;
    default:
        break;
    }
}

- (void)launchDrawerControllerAnimated:(BOOL)animated intoSettings:(BOOL)openSettings
{
    if ([self createDrawerViewController]) { // if already created, ignore
        if (openSettings) {
            [self openSettingsDrawer];
        }

        if ([self presentedViewController] != nil) {
            [[[self presentedViewController] view] addSubview:[[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO]];
            [self dismissViewControllerAnimated:animated completion:nil];
        }
    }
}

- (void)launchOnboarding:(BOOL)animated
{
    if ([self presentedViewController] != nil)
        return;

    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    HEMOnboardingCheckpoint checkpoint = [service onboardingCheckpoint];
    UIViewController* controller = [HEMOnboardingController controllerForCheckpoint:checkpoint force:NO];

    if (controller != nil) {
        [self presentViewController:controller animated:animated completion:^{
            [self removeDrawerViewController];
        }];
    } else {
        [SENAnalytics trackErrorWithMessage:@"attempt to launch onboarding with no controller"];
    }
}

- (void)didAuthorize
{
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    if ([service hasFinishedOnboarding]) {
        [self showArea:HEMRootAreaBackView animated:YES];
    }
    [[self systemAlertPresenter] setEnable:[self shouldMonitorSystem]];
}

- (void)didFinishOnboarding
{
    [self showArea:HEMRootAreaTimeline animated:YES];
}

- (void)showOnboarding
{
    [self showArea:HEMRootAreaOnboarding animated:YES];
}

- (BOOL)isShowingOnboarding
{
    return [self presentedViewController] != nil;
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController*)drawerViewController
                mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState
                        forDirection:(MSDynamicsDrawerDirection)direction
{
    switch (paneState) {
    case MSDynamicsDrawerPaneStateClosed:
        [[NSNotificationCenter defaultCenter] postNotificationName:HEMRootDrawerMayCloseNotification
                                                            object:nil];
        break;
    case MSDynamicsDrawerPaneStateOpen:
        [[NSNotificationCenter defaultCenter] postNotificationName:HEMRootDrawerMayOpenNotification
                                                            object:nil];
        break;
    default:
        break;
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController*)drawerViewController
                didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState
                        forDirection:(MSDynamicsDrawerDirection)direction
{
    switch (paneState) {
    case MSDynamicsDrawerPaneStateClosed:
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, NSLocalizedString(@"drawer.action.close", nil));
        [[NSNotificationCenter defaultCenter] postNotificationName:HEMRootDrawerDidCloseNotification
                                                            object:nil];
        [SENAnalytics track:kHEMAnalyticsEventTimelineClose];
        break;
    case MSDynamicsDrawerPaneStateOpen:
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, NSLocalizedString(@"drawer.action.open", nil));
        [[NSNotificationCenter defaultCenter] postNotificationName:HEMRootDrawerDidOpenNotification
                                                            object:nil];
        [SENAnalytics track:kHEMAnalyticsEventTimelineOpen];
        break;
    default:
        break;
    }
}

#pragma mark - UIPageViewControllerDelegate for Timeline events

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed) {
        [SENAnalytics track:kHEMAnalyticsEventTimelineChanged];
    }
}

#pragma mark - Drawer

- (HEMSnazzBarController*)barController
{
    return (id)[self.drawerViewController drawerViewControllerForDirection:MSDynamicsDrawerDirectionTop];
}

- (void)setPaneVisible:(BOOL)visible animated:(BOOL)animated {
    MSDynamicsDrawerPaneState state = visible
        ? MSDynamicsDrawerPaneStateOpen : MSDynamicsDrawerPaneStateOpenWide;
    if (state == self.drawerViewController.paneState
        || self.drawerViewController.paneState == MSDynamicsDrawerPaneStateClosed
        || [self isAnimatingPaneState])
        return;

    if (animated) {
        [self animatePaneVisible:visible];
    } else {
        [self.drawerViewController setPaneState:state];
    }
}

- (void)animatePaneVisible:(BOOL)visible {
    UIView* paneView = self.drawerViewController.paneView;
    CGRect windowBounds = HEMKeyWindowBounds();
    CGRect targetFrame = paneView.frame;
    targetFrame.origin.y = CGRectGetMaxY(windowBounds) + self.drawerViewController.paneStateOpenWideEdgeOffset;
    CGRect startFrame = CGRectMake(0,
                                   [self drawerPaneRevealHeight],
                                   CGRectGetWidth(paneView.bounds),
                                   CGRectGetHeight(paneView.bounds));
    if (visible) {
        [self animatePaneFrom:targetFrame to:startFrame state:MSDynamicsDrawerPaneStateOpen];
    } else {
        [self animatePaneFrom:startFrame to:targetFrame state:MSDynamicsDrawerPaneStateOpenWide];
    }
}

- (void)animatePaneFrom:(CGRect)startFrame to:(CGRect)targetFrame state:(MSDynamicsDrawerPaneState)state {
    self.animatingPaneState = YES;
    UIView* paneView = self.drawerViewController.paneView;
    paneView.frame = startFrame;
    [UIView animateWithDuration:0.18f animations:^{
        paneView.frame = targetFrame;
    } completion:^(BOOL finished) {
        [self.drawerViewController setPaneState:state];
        self.animatingPaneState = NO;
    }];
}

- (void)showSettingsDrawerTabAtIndex:(HEMRootDrawerTab)tabIndex animated:(BOOL)animated
{
    [self openSettingsDrawer];
    HEMSnazzBarController* controller = [self barController];
    UIViewController* topVC = [controller selectedViewController];
    // this is not an ideal way of handling it, but there really isn't
    // a good place or better way to do it so this is as good as anything?
    void(^popToRoot)(void) = ^{
        if ([topVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController* nav = (id)topVC;
            [nav popToRootViewControllerAnimated:NO];
        }
    };
    if ([topVC presentedViewController]) {
        [topVC dismissViewControllerAnimated:NO completion:popToRoot];
    } else {
        popToRoot ();
    }
    [controller setSelectedIndex:tabIndex animated:animated];
}

- (void)hideSettingsDrawerTopBar:(BOOL)hidden animated:(BOOL)animated
{
    HEMSnazzBarController* controller = [self barController];
    [controller hideBar:hidden animated:animated];
}

- (void)showPartialSettingsDrawerTopBarWithRatio:(CGFloat)ratio
{
    HEMSnazzBarController* controller = [self barController];
    [controller showPartialBarWithRatio:ratio];
}

- (void)openSettingsDrawer
{
    [self setPaneState:MSDynamicsDrawerPaneStateOpen];
}

- (void)closeSettingsDrawer
{
    [self setPaneState:MSDynamicsDrawerPaneStateClosed];
}

- (void)toggleSettingsDrawer
{
    switch (self.drawerViewController.paneState) {
    case MSDynamicsDrawerPaneStateClosed:
        [self openSettingsDrawer];
        break;
    case MSDynamicsDrawerPaneStateOpen:
    case MSDynamicsDrawerPaneStateOpenWide:
    default:
        [self closeSettingsDrawer];
        break;
    }
}

- (void)setPaneState:(MSDynamicsDrawerPaneState)state
{
    [self.drawerViewController setPaneState:state
                                   animated:YES
                      allowUserInterruption:YES
                                 completion:NULL];
}

#pragma mark - Shake to Show Debug Options

- (BOOL)canBecomeFirstResponder {
    return [HEMDebugController isEnabled];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent*)event {
    if ([HEMConfig booleanForConfig:HEMConfAllowDebugOptions] && motion == UIEventSubtypeMotionShake) {
        if ([self debugController] == nil) {
            [self setDebugController:[[HEMDebugController alloc] initWithViewController:self]];
        }
        [[self debugController] showSupportOptions];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
