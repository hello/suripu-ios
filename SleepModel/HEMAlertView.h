//
//  HEMAlertView.h
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^HEMDialogActionBlock)(void);
typedef void (^HEMDialogLinkActionBlock)(NSURL *link);

typedef NS_ENUM(NSUInteger, HEMAlertViewType) {
    HEMAlertViewTypeVertical = 0,
    HEMAlertViewTypeBoolean = 1,
};

typedef NS_ENUM(NSUInteger, HEMAlertViewButtonStyle) {
    HEMAlertViewButtonStyleRoundRect,
    HEMAlertViewButtonStyleBlueText,
    HEMAlertViewButtonStyleBlueBoldText,
    HEMAlertViewButtonStyleGrayText,
};

@interface HEMAlertView : UIView

/**
 * Initialize the dialog with an image that sits
 * above the title, the title of the message, and
 * the message for the dialog to display
 *
 * @param image   the image to show above the title
 * @param title   the title of the dialog
 * @param type    the button layout for the alert, either
 *                vertical or boolean (yes/no)
 * @param message the attributed message of the dialog
 */
- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                         type:(HEMAlertViewType)type
            attributedMessage:(NSAttributedString *)message;

/**
 * Set the callback to invoke when user taps on the 'okay' button
 * @param doneBlock: the block to invoke
 */
- (void)setCompletionBlock:(HEMDialogActionBlock)doneBlock;

/**
 * Add additional action buttons with the title and the block to call when user
 * taps on it
 * @param title: the text for the button
 * @param style: button style
 * @param blocK: the block to invoke when button is pressed
 */
- (void)addActionButtonWithTitle:(NSString *)title style:(HEMAlertViewButtonStyle)style action:(HEMDialogActionBlock)block;

/**
 * Set the callback to invoke when a link in the body of the alert is pressed
 *
 * @param url:         the url string that should trigger the action block
 * @param actionBlock: the block to call when the url is tapped on
 */
- (void)onLink:(NSString *)url tap:(HEMDialogLinkActionBlock)actionBlock;

@end
