//
//  HEMSnazzBarController.h
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMSnazzBarHeight;

@class HEMSnazzBarController;

@protocol HEMSnazzBarControllerChild <NSObject>

@optional
- (void)snazzViewDidAppear;
- (void)snazzViewWillDisappear;

@end

@protocol HEMSnazzBarControllerDelegate <NSObject>

@optional

/**
 *  Whether the controller should select and show the child view controller at an index. Default
 *  is YES.
 *
 *  @param barController the controller
 *  @param index         the index of the controller to show
 *
 *  @return YES if the controller should show the child view controller at index
 */
- (BOOL)barController:(HEMSnazzBarController*)barController shouldSelectIndex:(NSUInteger)index;

/**
 *  Invoked before the controller changes selected indices
 *
 *  @param barController the controller
 *  @param index         the new selected index
 */
- (void)barController:(HEMSnazzBarController*)barController willSelectIndex:(NSUInteger)index;

/**
 *  Invoked after the controller changes selected indices
 *
 *  @param barController the controller
 *  @param index         the current selected index
 */
- (void)barController:(HEMSnazzBarController*)barController didSelectIndex:(NSUInteger)index;
@end

/**
 *  A fancy top-of-screen tab bar controller, with support for swiping from one controller
 *  to the next.
 */
@interface HEMSnazzBarController : UIViewController

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (UIViewController*)selectedViewController;

- (void)hideBar:(BOOL)hidden animated:(BOOL)animated;
- (void)showPartialBarWithRatio:(CGFloat)ratio;
- (void)reloadButtonsBarBadges;

@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) id<HEMSnazzBarControllerDelegate> delegate;
@end
