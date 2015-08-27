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
#import "HEMActionView.h"
#import "HEMSystemAlertController.h"
#import "HEMSleepGraphViewController.h"
#import "HEMDynamicsStatusStyler.h"
#import "HEMBaseController+Protected.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMAppDelegate.h"
#import "HEMConfig.h"
#import "HEMTimelineContainerViewController.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingController.h"
#import "HEMAppUsage.h"

NSString* const HEMRootDrawerMayOpenNotification = @"HEMRootDrawerMayOpenNotification";
NSString* const HEMRootDrawerMayCloseNotification = @"HEMRootDrawerMayCloseNotification";
NSString* const HEMRootDrawerDidOpenNotification = @"HEMRootDrawerDidOpenNotification";
NSString* const HEMRootDrawerDidCloseNotification = @"HEMRootDrawerDidCloseNotification";

@interface HEMRootViewController () <MSDynamicsDrawerViewControllerDelegate, UIPageViewControllerDelegate>

@property (strong, nonatomic) HEMDebugController* debugController;
@property (strong, nonatomic) HEMSystemAlertController* alertController;
@property (strong, nonatomic) MSDynamicsDrawerViewController* drawerViewController;
@property (assign, nonatomic, getter=isMainControllerLoaded) BOOL mainControllerLoaded;
@property (nonatomic, getter=isAnimatingPaneState) BOOL animatingPaneState;
@end

@implementation HEMRootViewController

CGFloat const HEMRootDrawerDefaultGravityMagnitude = 2.5;
CGFloat const HEMRootDrawerAnimationGravityMagnitude = 1.f;
static CGFloat const HEMRootDrawerRevealHeight = 46.f;
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
        [HEMMainStoryboard instantiateAlarmListNavViewController],
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
        startDate = [[NSDate date] previousDay];
    
    HEMSleepSummarySlideViewController* slideController = [[HEMSleepSummarySlideViewController alloc] initWithDate:startDate];
    [slideController setDelegate:self];

    HEMTimelineContainerViewController* container = [HEMMainStoryboard instantiateTimelineContainerController];
    [container setTimelineController:slideController];

    return container;
}

- (void)viewDidBecomeActive
{
    [super viewDidBecomeActive];
    [[self alertController] enableSystemMonitoring:[self shouldMonitorSystem]];
    
    [HEMAppUsage appUsageForIdentifier:HEMAppUsageAppLaunched];
    [SENAnalytics track:kHEMAnalyticsEventAppLaunched];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setAlertController:[[HEMSystemAlertController alloc] initWithViewController:self]];
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
    MSDynamicsDrawerShadowStyler* shadowStyler = [MSDynamicsDrawerShadowStyler styler];
    shadowStyler.shadowRadius = 3.f;
    shadowStyler.shadowOpacity = 0.2f;
    [self.drawerViewController addStylersFromArray:@[ [HEMDynamicsStatusStyler styler], shadowStyler ]
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
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = MIN(CGRectGetHeight(statusBarFrame), CGRectGetWidth(statusBarFrame));
    CGFloat screenHeight = MAX(CGRectGetHeight(screenFrame), CGRectGetWidth(screenFrame));
    return screenHeight - (HEMRootDrawerRevealHeight + statusBarHeight - HEMRootDrawerStatusBarOffset);
}

- (void)adjustRevealHeight
{
    MSDynamicsDrawerPaneState state = self.drawerViewController.paneState;
    self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
    [self.drawerViewController setRevealWidth:[self drawerPaneRevealHeight] forDirection:MSDynamicsDrawerDirectionTop];
    self.drawerViewController.paneState = state;
    self.drawerViewController.view.frame = [[UIScreen mainScreen] bounds];
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
}

- (BOOL)shouldMonitorSystem
{
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    HEMOnboardingCheckpoint checkpoint = [service onboardingCheckpoint];
    return [SENAuthorizationService isAuthorized]
        && [self presentedViewController] == nil
        && (checkpoint == HEMOnboardingCheckpointStart
               || checkpoint == HEMOnboardingCheckpointPillDone);
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
        UINavigationController* onboardingNav
            = [[HEMStyledNavigationViewController alloc] initWithRootViewController:controller];
        [[onboardingNav navigationBar] setTintColor:[UIColor tintColor]];

        [self presentViewController:onboardingNav animated:animated completion:^{
            [self showStatusBar];
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
        [self showArea:HEMRootAreaTimeline animated:YES];
    }
    [[self alertController] enableSystemMonitoring:[self shouldMonitorSystem]];
}

- (void)didFinishOnboarding
{
    [self showArea:HEMRootAreaBackView animated:YES];
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
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect targetFrame = paneView.frame;
    targetFrame.origin.y = CGRectGetMaxY(screenBounds) + self.drawerViewController.paneStateOpenWideEdgeOffset;
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

- (BOOL)canBecomeFirstResponder
{
    return [HEMDebugController isEnabled];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent*)event
{
    if ([HEMConfig booleanForConfig:HEMConfAllowDebugOptions] && motion == UIEventSubtypeMotionShake) {
        if ([self debugController] == nil) {
            [self setDebugController:[[HEMDebugController alloc] initWithViewController:self]];
        }
        [[self debugController] showSupportOptions];
    }
}

#pragma mark - Cleanup

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
