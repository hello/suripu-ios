//
//  HEMHandholdingOverlayView.h
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMHHDialogAnchor) {
    HEMHHDialogAnchorTop = 1,
    HEMHHDialogAnchorBottom = 2,
};

typedef void(^HEMHandHoldingDismissal)(BOOL shown);

extern CGFloat const HEMHandholdingGestureSize;

@interface HEMHandholdingView : UIView

/**
 * @property gestureStartCenter
 *
 * Set the starting center point for the handholding gesture
 */
@property (nonatomic, assign) CGPoint gestureStartCenter;

/**
 * @property gestureEndCenter
 *
 * Set the end center point for the handholding gesture
 */
@property (nonatomic, assign) CGPoint gestureEndCenter;

/**
 * @property anchor
 *
 * Specifiy the anchor in which the message will be displayed at within the
 * view.  It defaults to HEMHHDialogAnchorTop
 */
@property (nonatomic, assign) HEMHHDialogAnchor anchor;

/**
 * @property message
 *
 * The message to be displayed while the gesture animation is happening.  If
 * not set, the message dialog / view will not be displayed
 */
@property (nonatomic, copy)   NSString* message;

/**
 * @method showInView:
 *
 * Show this handholding view inside the view specified.
 *
 * @param view: the view to attach itself to
 * @param contentView: the view that the tutorial is meant to target
 * @param dismissal: the block to call if user taps on the dimiss button, but not
 *                   if user simply taps out of this view via gesture
 * @return YES if it was shown, no otherwise
 */
- (void)showInView:(UIView*)view
   fromContentView:(UIView*)contentView
     dismissAction:(HEMHandHoldingDismissal)dismissal;

@end
