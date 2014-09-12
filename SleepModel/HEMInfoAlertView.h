//
//  HEMSleepQuestionAlertView.h
//  Sense
//
//  Created by Jimmy Lu on 9/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMInfoAlertView : UIView

/**
 * Initiallze the alert view with the information to present.  The space for
 * the information text is limited to 2 lines and will use ellipsis if it's
 * beyond the bounds.
 *
 * By default, this will show a question mark icon
 *
 * @param info: text to display
 * @return      initialized instance
 */
- (id)initWithInfo:(NSString*)info;

/**
 * Initialize the view with the info text and icon to display.
 *
 * @param info: text to display
 * @param icon: the icon to display to the left of the icon
 * @return      initialized instance
 */
- (id)initWithInfo:(NSString*)info andIcon:(UIImage*)icon;

/**
 * Add a target and action selector to react to user tapping on the viwe
 * @param target: the target for the action
 * @param action: the selector to invoke.  Sender argument should not be assumed
 */
- (void)addTarget:(id)target action:(SEL)action;

/**
 * Show this alert in the view specified, which will add itself to it and animate
 * from below the view up until it's fully visible
 * 
 * @param animated:   YES to animate the action, NO otherwise
 * @param completion: the block to invoke when view has been shown
 */
- (void)showInView:(UIView*)view
          animated:(BOOL)animated
        completion:(void(^)(void))completionl;

/**
 * Dismiss the alert, which will hide itself by reversing the show animation
 * and then removing itself form the view
 * @param animated:   YES if this should be animated, NO otherwise
 * @param completion: the completion block to invoke when this has been dismissed
 */
- (void)dismiss:(BOOL)animated completion:(void(^)(void))completion;

@end
