//
//  HEMSlideViewController.h
//  Sense
//
//  This class is a container controller that manages controllers similar to a
//  UIScrollView with paging enabled, but shows gaps as the controllers are
//  transitioning.
//
//  At the moment, this controller requests the next controller to be displayed
//  lazily and so if caching from the data source is not done, then there may
//  be a slight performance hiccup as the sliding starts.  Until optimistic
//  loading of the controllers is implemented here, you can make the transitions
//  more performant by making sure child controllers are created fast, minimizing
//  what loadView or viewDidLoad does.  An alternative or perhaps in addition to
//  this, the data source can also provide the caching mechanism.
//
//  Created by Jimmy Lu on 8/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMSlideViewController;

@protocol HEMSlideViewControllerDataSource <NSObject>

/**
 * Ask the data source for a controller that comes before (to the left) of the
 * current controller specified.
 * @param slideController: a HEMSlideViewController container
 * @param controller: the current controller
 * @return controller before current, or nil if none is available
 */
- (UIViewController*)slideViewController:(HEMSlideViewController*)slideController
                        controllerBefore:(UIViewController*)controller;

/**
 * Ask the data source for a controller that comes after (to the right) of the
 * current controller specified.
 * @param slideController: a HEMSlideViewController container
 * @param controller: the current controller
 * @return controller after current, or nil if none is available
 */
- (UIViewController*)slideViewController:(HEMSlideViewController*)slideController
                         controllerAfter:(UIViewController*)controller;

@end

@protocol HEMSlideViewControllerDelegate <NSObject>

@optional

/**
 * Tells the delegate that sliding has begun
 * @param slideController: the instance calling the delegate
 */
- (void)slideViewControllerDidBeginSliding:(HEMSlideViewController*)slideController;

/**
 * Tells the delegate that sliding has ended
 * @param slideController: the instance calling the delegate
 */
- (void)slideViewControllerDidEndSliding:(HEMSlideViewController*)slideController;

/**
 * Tells the delegate while the sliding is happening in case controllers want to
 * animate with the current motion.  This is called only when the user is initiating
 * the motion and not when user lets go and the container takes over.
 *
 * @param slideController: the instance calling the delegate
 * @param x: the amount in the X-axis that has moved so far
 */
- (void)slideviewController:(HEMSlideViewController*)slideController
                didSlideByX:(CGFloat)x;

@end

@interface HEMSlideViewController : UIViewController

@property (nonatomic, weak) id<HEMSlideViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<HEMSlideViewControllerDelegate> delegate;

/**
 * Initialize the container with the intiial controller to display
 * @param controller: the controller to display first and will be the point of
 *                    reference to the data source.
 * @return an initialized instance of this container controller
 */
- (id)initWithInitialController:(UIViewController*)controller;

@end
