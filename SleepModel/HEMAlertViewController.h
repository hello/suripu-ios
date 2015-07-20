//
//  HEMAlertViewController.h
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMAlertView.h"

@interface HEMAlertViewController : UIViewController

// properties should be set prior to showing the dialog
/**
 *  View blurred under the popup
 */
@property (nonatomic, weak)   UIView* viewToShowThrough;
@property (nonatomic, strong) UIImage* dialogImage;
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, copy)   NSString* message;
@property (nonatomic, copy)   NSAttributedString* attributedMessage;

/**
 *  Title of the default (primary) button
 */
@property (nonatomic, copy)   NSString* defaultButtonTitle;

/**
 * @property helpURL
 *
 * @discussion
 * This is the "slug" or page path to the help guide.  If this is not set, the
 * troubleshooting button will not be shown
 */
@property (nonatomic, copy)   NSString* helpPage;

/**
 *  Present a non-interactive dialog
 *
 *  @param title      title of the dialog
 *  @param message    dialog message content
 *  @param controller presenting controller
 */
+ (void)showInfoDialogWithTitle:(NSString*)title message:(NSString*)message controller:(UIViewController*)controller;

/**
 *  Present a dialog with "yes" and "no" as possible options, where answering
 *  "yes" (default) performs an action, and no dismisses the dialog without
 *  further interaction.
 *
 *  @param title      title of the dialog
 *  @param message    dialog message content
 *  @param controller presenting controller
 *  @param action     block executed when answer is "yes"
 */
+ (void)showBooleanChoiceDialogWithTitle:(NSString *)title
                                 message:(NSString *)message
                              controller:(UIViewController *)controller
                                  action:(void (^)())action;

/**
 * Add additional action buttons to the dialog
 * @param title:   title of the action button
 * @param primary: YES if primary action, NO otherwise
 * @param block:   the block to invoke when button is tapped
 */
- (void)addAction:(NSString*)title primary:(BOOL)primary actionBlock:(HEMDialogActionBlock)block;

/**
 * If the message set has a link, this configures the dialog to forward the tap
 * to the the block specified
 *
 * @param url:    the url of the link
 * @param action: the block to invoke when a tap to the link is detected
 */
- (void)onLinkTapOf:(NSString*)url takeAction:(HEMDialogLinkActionBlock)action;

/**
 * Call this method to show the actual dialog, which will present itself.  Do not
 * present this view controller yourself if calling this method
 *
 * @param controller: the controller that is presenting this dialog
 * @param doneBlock:  the block to invoke when user taps on the default button
 */
- (void)showFrom:(UIViewController*)controller onDefaultActionSelected:(HEMDialogActionBlock)doneBlock;

/**
 * Call this method if you are presenting this controller yourself, which will
 * show the dialog.  If using this method, call it after you have presented the
 * controller for optimal experience
 *
 * @param doneBlock:  the block to invoke when user taps on Okay button
 */
- (void)show:(HEMDialogActionBlock)doneBlock;

@end
