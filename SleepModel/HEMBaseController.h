//
//  HEMBaseController.h
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMNavigationShadowView.h"

@class HEMPresenter;
@class HEMRootViewController;

NS_ASSUME_NONNULL_BEGIN

@interface HEMBaseController : UIViewController

@property (nonatomic, strong, readonly) HEMNavigationShadowView* shadowView;
@property (nullable, nonatomic, strong, readonly) NSArray<HEMPresenter*>* presenters;

- (void)addPresenter:(HEMPresenter*)presenter;

/**
 * @return the root view controller
 */
- (UIViewController*)rootViewController;

/**
 * @discussion
 * Subclasses should override this value if a shadow view underneath the navigation
 * bar should never be shown.  Defaults to YES
 *
 * @return YES to show the shadow view, NO otherwise
 */
- (BOOL)wantsShadowView;

/**
 * @return the "see through view" to display underneath alerts
 */
- (UIView*)backgroundViewForAlerts;

/**
 * @return YES if the view of this view controller is fully visible within the
 *         the current window.  No otherwise, even if only 1 pt is out of the
 *         viewport
 */
- (BOOL)isFullyVisibleInWindow;

@end

@interface HEMBaseController (Subclass)

- (void)enableBackButton:(BOOL)enable;
- (void)adjustConstraintsForIPhone4;
- (void)adjustConstraintsForIphone5;
- (void)updateConstraint:(NSLayoutConstraint*)constraint withDiff:(CGFloat)diff;
- (void)showMessageDialog:(NSString*)message title:(NSString*)title;
- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                    image:(UIImage*)image
             withHelpPage:(NSString*)helpPage;
- (void)viewDidBecomeActive;
- (void)viewDidEnterBackground;
- (BOOL)showIndicatorForCrumb:(NSString*)crumb;
- (void)clearCrumb:(NSString*)crumb;
- (void)reloadTopBar;
- (void)didRefreshAccount;

@end

NS_ASSUME_NONNULL_END
