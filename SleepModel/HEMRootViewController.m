//
//  HEMRootViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceDevice.h>

#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "UIView+HEMMotionEffects.h"

#import "HEMRootViewController.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HelloStyleKit.h"
#import "HEMSnazzBarController.h"
#import "HEMMainStoryboard.h"
#import "HEMDebugController.h"
#import "HEMActionView.h"
#import "HEMOnboardingUtils.h"
#import "HEMSystemAlertController.h"
#import "HEMSleepGraphViewController.h"
#import "HEMDynamicsStatusStyler.h"
#import "HEMBaseController+Protected.h"
#import "HEMAppDelegate.h"

NSString* const HEMRootDrawerMayOpenNotification = @"HEMRootDrawerMayOpenNotification";
NSString* const HEMRootDrawerMayCloseNotification = @"HEMRootDrawerMayCloseNotification";
NSString* const HEMRootDrawerDidOpenNotification = @"HEMRootDrawerDidOpenNotification";
NSString* const HEMRootDrawerDidCloseNotification = @"HEMRootDrawerDidCloseNotification";

@interface HEMRootViewController ()<MSDynamicsDrawerViewControllerDelegate>

@property (strong, nonatomic) HEMDebugController* debugController;
@property (strong, nonatomic) HEMSystemAlertController* alertController;
@property (strong, nonatomic) MSDynamicsDrawerViewController* drawerViewController;

@end

@implementation HEMRootViewController

static CGFloat const HEMRootTopPaneParallaxDepth = 4.f;
static CGFloat const HEMRootDrawerRevealHeight = 46.f;
static CGFloat const HEMRootDrawerRevealHeightStatusOffset = 20.f;

+ (instancetype)rootViewControllerForKeyWindow
{
    HEMAppDelegate* delegate = (id)[UIApplication sharedApplication].delegate;
    return (id)delegate.window.rootViewController;
}

+ (UIViewController*)instantiateDrawerViewController {
    HEMSnazzBarController* barController = [HEMSnazzBarController new];
    barController.viewControllers = @[
        [HEMMainStoryboard instantiateCurrentNavController],
        [HEMMainStoryboard instantiateTrendsViewController],
        [HEMMainStoryboard instantiateInsightFeedViewController],
        [HEMMainStoryboard instantiateAlarmListNavViewController],
        [HEMMainStoryboard instantiateSettingsNavController]];
    barController.selectedIndex = 2;
    return barController;
}

/**
 *  Creates a new pane controller
 *
 *  @param startDate the presented date of the controller. May be nil.
 *
 *  @return a new pane controller
 */
+ (UIViewController*)instantiatePaneViewControllerWithDate:(NSDate*)startDate {
    HEMSleepSummarySlideViewController* slideController;
    if (startDate)
        slideController = [[HEMSleepSummarySlideViewController alloc] initWithDate:startDate];
    else
        slideController = [HEMSleepSummarySlideViewController new];
    [slideController.view add3DEffectWithBorder:HEMRootTopPaneParallaxDepth
                                      direction:HEMMotionEffectsDirectionVertical];
    return slideController;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setAlertController:[[HEMSystemAlertController alloc] initWithViewController:self]];
        [self registerForNotifications];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createDrawerViewController];
}

- (void)viewDidBecomeActive
{
    [super viewDidBecomeActive];
    [[self alertController] enableDeviceMonitoring:[self shouldMonitorDevices]];
    [SENAnalytics track:kHEMAnalyticsEventAppLaunched];
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

- (UIViewController *)backController
{
    return [self.drawerViewController drawerViewControllerForDirection:MSDynamicsDrawerDirectionTop];
}

- (UIViewController *)frontController
{
    return self.drawerViewController.paneViewController;
}

- (BOOL)drawerIsVisible
{
    return self.drawerViewController.paneState != MSDynamicsDrawerPaneStateClosed;
}

- (void)createDrawerViewController
{
    self.drawerViewController = [MSDynamicsDrawerViewController new];
    self.drawerViewController.paneViewController = [HEMRootViewController instantiatePaneViewControllerWithDate:nil];
    self.drawerViewController.delegate = self;
    self.drawerViewController.gravityMagnitude = 2.5;
    [self hideStatusBar];
    [self.drawerViewController addStylersFromArray:@[[HEMDynamicsStatusStyler styler]]
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
}

- (void)adjustRevealHeight
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = MIN(CGRectGetHeight(statusBarFrame), CGRectGetWidth(statusBarFrame));
    CGFloat screenHeight = MAX(CGRectGetHeight(screenFrame), CGRectGetWidth(screenFrame));
    CGFloat revealHeight = screenHeight
        - (HEMRootDrawerRevealHeight + statusBarHeight - HEMRootDrawerRevealHeightStatusOffset);
    MSDynamicsDrawerPaneState state = self.drawerViewController.paneState;
    self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
    [self.drawerViewController setRevealWidth:revealHeight forDirection:MSDynamicsDrawerDirectionTop];
    self.drawerViewController.paneState = state;
}

- (void)registerForNotifications {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didAuthorize)
                   name:SENAuthorizationServiceDidAuthorizeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(adjustRevealHeight)
                   name:UIApplicationDidChangeStatusBarFrameNotification
                 object:nil];
}

- (void)didAuthorize {
    [self showSettingsDrawerTabAtIndex:HEMRootDrawerTabInsights animated:NO];
}

- (BOOL)shouldMonitorDevices {
    HEMOnboardingCheckpoint checkpoint = [HEMOnboardingUtils onboardingCheckpoint];
    return [SENAuthorizationService isAuthorized]
            && [self presentedViewController] == nil
            && (checkpoint == HEMOnboardingCheckpointStart
                || checkpoint == HEMOnboardingCheckpointPillDone);
}

- (void)reloadTimelineSlideViewControllerWithDate:(NSDate *)date
{
    UIViewController* controller = [HEMRootViewController instantiatePaneViewControllerWithDate:date];
    [self.drawerViewController setPaneViewController:controller
                                            animated:NO
                                          completion:NULL];
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
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

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController
                didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState
                        forDirection:(MSDynamicsDrawerDirection)direction
{
    switch (paneState) {
        case MSDynamicsDrawerPaneStateClosed:
            [[NSNotificationCenter defaultCenter] postNotificationName:HEMRootDrawerDidCloseNotification
                                                                object:nil];
            break;
        case MSDynamicsDrawerPaneStateOpen:
            [[NSNotificationCenter defaultCenter] postNotificationName:HEMRootDrawerDidOpenNotification
                                                                object:nil];
            break;
        default:
            break;
    }
}

#pragma mark - Drawer

- (HEMSnazzBarController*)barController
{
    return (id)[self.drawerViewController drawerViewControllerForDirection:MSDynamicsDrawerDirectionTop];
}

- (void)showSettingsDrawerTabAtIndex:(HEMRootDrawerTab)tabIndex animated:(BOOL)animated {
    [self openSettingsDrawer];
    HEMSnazzBarController* controller = [self barController];
    [controller setSelectedIndex:tabIndex animated:animated];
}

- (void)hideSettingsDrawerTopBar:(BOOL)hidden animated:(BOOL)animated {
    HEMSnazzBarController* controller = [self barController];
    [controller hideBar:hidden animated:animated];
}

- (void)showPartialSettingsDrawerTopBarWithRatio:(CGFloat)ratio {
    HEMSnazzBarController* controller = [self barController];
    [controller showPartialBarWithRatio:ratio];
}

- (void)openSettingsDrawer {
    [self setPaneState:MSDynamicsDrawerPaneStateOpen];
}

- (void)closeSettingsDrawer {
    [self setPaneState:MSDynamicsDrawerPaneStateClosed];
}

- (void)toggleSettingsDrawer {
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

- (void)setPaneState:(MSDynamicsDrawerPaneState)state {
    [self.drawerViewController setPaneState:state
                                   animated:YES
                      allowUserInterruption:YES
                                 completion:NULL];
}


#pragma mark - Shake to Show Debug Options

- (BOOL)canBecomeFirstResponder {
    return [HEMDebugController isEnabled];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
#if BETA
    if (motion == UIEventSubtypeMotionShake) {
        if ([self debugController] == nil) {
            [self setDebugController:[[HEMDebugController alloc] initWithViewController:self]];
        }
        [[self debugController] showSupportOptions];
    }
#endif
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
