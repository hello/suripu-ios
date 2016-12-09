//
//  HEMActionView.h
//  Sense
//
//  Created by Jimmy Lu on 12/1/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMActionView : UIView

@property (nonatomic, weak, readonly) UIButton* cancelButton;
@property (nonatomic, weak, readonly) UIButton* okButton;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger subtype;

/**
 * Initialize the instance with a title and message to display
 *
 * @param title:             an optional title for the action view
 * @param attributedMessage: expected message to display (required)
 * @return                   instance of HEMActionView
 */
- (instancetype)initWithTitle:(NSString*)title message:(NSAttributedString*)attributedMessage;

/**
 * Initialize the instance with a custom title view and message to display.  The
 * custom view will be shrunken (or enlarged) to a width and default height defined
 * by this view so ensure that the custom view can layout accordingly
 *
 * @param title:             an optional custom view for the action view
 * @param attributedMessage: expected message to display (required)
 * @return                   instance of HEMActionView
 */
- (instancetype)initWithTitleView:(UIView*)titleView message:(NSAttributedString*)attributedMessage;

/**
 * Show this view inside the view specified, animated or not
 * @param view:       parent view for this view
 *
 * @param aniamted:   YES to animate the showing, NO otherwise
 * @param completion: the block to invoke when it's shown
 */
- (void)showInView:(UIView*)view below:(UIView*)topView animated:(BOOL)animated completion:(void(^)(void))completion;

/**
 * Dismiss this view, animated or not.  Upon completion, this view will be removed
 * from it's super view.
 *
 * @param animated: YES to animate it, NO otherwise
 * @param completion: the block to invoke when it's dismissed
 */
- (void)dismiss:(BOOL)animated completion:(void(^)(void))completion;

/**
 * Hide the OK button so that only the cancel button is visible.
 */
- (void)hideOkButton;

@end
