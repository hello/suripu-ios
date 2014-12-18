//
//  HEMRootViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import <SenseKit/SENAuthorizationService.h>

#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"

#import "HEMRootViewController.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HEMAlertController.h"
#import "HEMOnboardingUtils.h"
#import "HEMSupportUtil.h"
#import "HelloStyleKit.h"
#import "HEMSnazzBarController.h"
#import "HEMMainStoryboard.h"

@interface HEMRootViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) HEMAlertController* supportOptionController;

@end

@implementation HEMRootViewController

+ (NSArray*)instantiateInitialControllers {
    HEMSnazzBarController* barController = [HEMSnazzBarController new];
    barController.viewControllers = @[
        [HEMMainStoryboard instantiateCurrentNavController],
        [HEMMainStoryboard instantiateTrendsViewController],
        [HEMMainStoryboard instantiateInsightFeedViewController],
        [HEMMainStoryboard instantiateAlarmListNavViewController],
        [HEMMainStoryboard instantiateSettingsNavController]];
    barController.selectedIndex = 2;

    return @[barController, [HEMSleepSummarySlideViewController new]];
}

- (instancetype)init {

    self = [super initWithViewControllers:[HEMRootViewController instantiateInitialControllers]
                               hintOnLoad:YES];
    return self;
}

#pragma mark - Drawer

- (void)showSettingsDrawerTabAtIndex:(HEMRootDrawerTab)tabIndex animated:(BOOL)animated {
    [self openSettingsDrawer];
    FCDynamicPane* pane = [self.viewControllers firstObject];
    HEMSnazzBarController* controller = (id)pane.viewController;
    [controller setSelectedIndex:tabIndex animated:animated];
}

- (void)hideSettingsDrawerTopBar:(BOOL)hidden animated:(BOOL)animated {
    FCDynamicPane* pane = [self.viewControllers firstObject];
    HEMSnazzBarController* controller = (id)pane.viewController;
    [controller hideBar:hidden animated:animated];
}

- (void)showPartialSettingsDrawerTopBarWithRatio:(CGFloat)ratio {
    FCDynamicPane* pane = [self.viewControllers firstObject];
    HEMSnazzBarController* controller = (id)pane.viewController;
    [controller showPartialBarWithRatio:ratio];
}

- (void)openSettingsDrawer {
    FCDynamicPane* foregroundPane = [[self viewControllers] lastObject];
    if (foregroundPane != nil) {
        [foregroundPane setState:FCDynamicPaneStateRetracted];
    }
}

- (void)closeSettingsDrawer {
    FCDynamicPane* foregroundPane = [[self viewControllers] lastObject];
    if (foregroundPane != nil) {
        [foregroundPane setState:FCDynamicPaneStateActive];
    }
}

- (void)toggleSettingsDrawer {
    FCDynamicPane* foregroundPane = [[self viewControllers] lastObject];
    if (foregroundPane != nil) {
        FCDynamicPaneState state = foregroundPane.state == FCDynamicPaneStateActive
            ? FCDynamicPaneStateRetracted
            : FCDynamicPaneStateActive;
        [foregroundPane setState:state];
    }
}


#pragma mark - Shake to Show Support Options

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self showSupportOptions];
    }
}

- (void)showSupportOptions {
    if ([self supportOptionController] != nil) return; // don't show it if showing now
    
    // can't simply cache the alertcontroller and not recreate it as the presentingcontroller
    // is cached within it, which may be different each time this is called
    UIViewController* presentingController = [self presentedViewController] ?: self;
    NSString* title = NSLocalizedString(@"support.options.title", nil);
    HEMAlertController* sheet = [[HEMAlertController alloc] initWithTitle:title
                                                                  message:nil
                                                                    style:HEMAlertControllerStyleSheet
                                                     presentingController:presentingController];
    
    [self addContactSupportOptionTo:sheet];
    [self addResetCheckpointOptionTo:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet]; // need to hold on to it otherwise action callbacks will crash
    [[self supportOptionController] show];
}

- (void)addContactSupportOptionTo:(HEMAlertController*)sheet {
    UIViewController* presentingController = [self presentedViewController] ?: self;
    
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"support.option.contact-support", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [HEMSupportUtil contactSupportFrom:presentingController mailDelegate:strongSelf];
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

- (void)addResetCheckpointOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"support.option.reset", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([[strongSelf presentedViewController] isKindOfClass:[UINavigationController class]]) {
                UINavigationController* onboardingVC = (UINavigationController*)[strongSelf presentedViewController];
                UIViewController* startController = [HEMOnboardingUtils onboardingControllerForCheckpoint:HEMOnboardingCheckpointStart authorized:NO];
                if (![[onboardingVC topViewController] isKindOfClass:[startController class]]) {
                    [onboardingVC setViewControllers:@[startController] animated:YES];
                }
            }
            [strongSelf setSupportOptionController:nil];
            [SENAuthorizationService deauthorize];
        }
    }];
}

- (void)addCancelOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"actions.cancel", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

#pragma mark Support Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
