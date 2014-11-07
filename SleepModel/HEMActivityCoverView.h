//
//  HEMActivityCoverView.h
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMActivityCoverView : UIView

@property (nonatomic, strong, readonly) UILabel* activityLabel;
@property (nonatomic, assign, readonly, getter=isShowing) BOOL showing;

/**
 * @method
 * Show this activity view inside the specified view.  If you want to display this
 * over the navigationBar, then pass in the navigation controller's view
 *
 * @param view:       the view that this view will attach to when displayed
 * @param completion: the block the invoke when this has been shown
 */
- (void)showInView:(UIView*)view completion:(void(^)(void))completion;

/**
 * Show the activity with with initial text
 * @param view:       view this view should attach to
 * @param text:       initial text to display
 * @param activity:   YES to show an activity indicator, NO to show text only
 * @param completion: block to invoke on completion
 */
- (void)showInView:(UIView*)view
          withText:(NSString*)text
          activity:(BOOL)activity
        completion:(void(^)(void))completion;

/**
 * @method
 * Show this activity view inside the specified view.  If you want to display this
 * over the navigationBar, then pass in the navigation controller's view
 *
 * @param view:       the view that this view will attach to when displayed
 * @param activity:   YES to show activity, NO otherwise
 * @param completion: the block the invoke when this has been shown
 */
- (void)showInView:(UIView*)view activity:(BOOL)activity completion:(void(^)(void))completion;

/**
 * @method updateText:completion:
 *
 * @discussion
 * Update the currently displayed text without dismissing activyt indicator
 *
 * @param text: the text to show
 * @param completion: the block to invoke when text has been updated, if needed
 */
- (void)updateText:(NSString*)text completion:(void(^)(BOOL finished))completion;

/**
 * @method
 * Display the text specified, then dismiss the view after, calling the completion
 * block when all is done.
 * 
 * @param text:       text to display before dismissing
 * @param completion: the block to invoke when this has been dismissed
 */
- (void)dismissWithResultText:(NSString*)text
                   completion:(void(^)(void))completion;

@end
