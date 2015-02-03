//
//  HEMRootViewController.h
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "HEMBaseController.h"

typedef NS_ENUM(NSUInteger, HEMRootDrawerTab) {
    HEMRootDrawerTabConditions = 0,
    HEMRootDrawerTabTrends = 1,
    HEMRootDrawerTabInsights = 2,
    HEMRootDrawerTabAlarms = 3,
    HEMRootDrawerTabSettings = 4
};

extern NSString* const HEMRootDrawerMayOpenNotification;
extern NSString* const HEMRootDrawerMayCloseNotification;
extern NSString* const HEMRootDrawerDidOpenNotification;
extern NSString* const HEMRootDrawerDidCloseNotification;

@interface HEMRootViewController : HEMBaseController

- (void)reloadTimelineSlideViewControllerWithDate:(NSDate*)date;
- (void)hideSettingsDrawerTopBar:(BOOL)hidden animated:(BOOL)animated;
- (void)showPartialSettingsDrawerTopBarWithRatio:(CGFloat)ratio;
- (void)showSettingsDrawerTabAtIndex:(HEMRootDrawerTab)tabIndex animated:(BOOL)animated;

- (void)openSettingsDrawer;
- (void)closeSettingsDrawer;
- (void)toggleSettingsDrawer;

- (BOOL)drawerIsVisible;

/**
 *  The "back" pane controller
 *
 *  @return a view controller or nil
 */
- (UIViewController*)backController;

/**
 *  The "front" pane controller
 *
 *  @return a view controller or nil
 */
- (UIViewController*)frontController;

@end
