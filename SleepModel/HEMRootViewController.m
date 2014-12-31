//
//  HEMRootViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

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

@interface HEMRootViewController ()

@property (strong, nonatomic) HEMDebugController* debugController;
@property (strong, nonatomic) HEMSystemAlertController* alertController;

@end

@implementation HEMRootViewController

static CGFloat const HEMRootTopPaneParallaxDepth = 4.f;

+ (NSArray*)instantiateInitialControllers {
    HEMSnazzBarController* barController = [HEMSnazzBarController new];
    barController.viewControllers = @[
        [HEMMainStoryboard instantiateCurrentNavController],
        [HEMMainStoryboard instantiateTrendsViewController],
        [HEMMainStoryboard instantiateInsightFeedViewController],
        [HEMMainStoryboard instantiateAlarmListNavViewController],
        [HEMMainStoryboard instantiateSettingsNavController]];
    barController.selectedIndex = 2;
    HEMSleepSummarySlideViewController* slideController = [HEMSleepSummarySlideViewController new];
    [slideController.view add3DEffectWithBorder:HEMRootTopPaneParallaxDepth
                                      direction:HEMMotionEffectsDirectionVertical];
    return @[barController, slideController];
}

- (instancetype)init {

    self = [super initWithViewControllers:[HEMRootViewController instantiateInitialControllers]
                               hintOnLoad:YES];
    if (self) {
        [self setAlertController:[[HEMSystemAlertController alloc] initWithViewController:self]];
    }
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


#pragma mark - Shake to Show Debug Options

- (BOOL)canBecomeFirstResponder {
    return [HEMDebugController isEnabled];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        if ([self debugController] == nil) {
            [self setDebugController:[[HEMDebugController alloc] initWithViewController:self]];
        }
        [[self debugController] showSupportOptions];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    // really shouldn't have to since this is root
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
