//
//  HEMAlertView.h
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HEMDialogActionBlock)(void);
typedef void(^HEMDialogLinkActionBlock)(NSString* link);

@interface HEMAlertView : UIView

@property (nonatomic, weak, readonly) UIButton* okButton;

/**
 * Initiallize the dialog with an image that sits
 * above the title, the title of the message, and
 * the message for the dialog to display
 * 
 * @param image:   the image to show above the title
 * @param title:   the title of the dialog
 * @param message: the message of the dialog
 */
- (id)initWithImage:(UIImage*)image
              title:(NSString*)title
            message:(NSString*)message;

/**
 * Initiallize the dialog with an image that sits
 * above the title, the title of the message, and
 * the message for the dialog to display
 *
 * @param image:   the image to show above the title
 * @param title:   the title of the dialog
 * @param message: the message of the dialog
 * @param frame:   the frame of the dialog to initialize with, which will may or
 *                 may not be adjusted based on the contents of the view
 */
- (id)initWithImage:(UIImage*)image
              title:(NSString*)title
            message:(NSString*)message
              frame:(CGRect)frame;

/**
 * Set the callback to invoke when user taps on the 'okay' button
 * @param doneBlock: the block to invoke
 */
- (void)onDone:(HEMDialogActionBlock)doneBlock;


/**
 * Add additional action buttons with the title and the block to call when user
 * taps on it
 * @param title:   the text for the button
 * @param primary: YES if it's a primary button, NO otherwise
 * @param blocK:   the block to invoke when button is pressed
 */
- (void)addActionButtonWithTitle:(NSString*)title
                         primary:(BOOL)primary
                          action:(HEMDialogActionBlock)block;

/**
 * Set the callback to invoke when a link in the body of the alert is pressed
 * 
 * @param linkBlock: the block to call
 */
- (void)onLinkTap:(HEMDialogLinkActionBlock)linkBlock;

@end
