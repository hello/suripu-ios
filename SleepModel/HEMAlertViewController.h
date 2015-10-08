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
@property (nonatomic, copy)   NSAttributedString* attributedMessage;
@property (nonatomic) HEMAlertViewType type;

/**
 *  Present a non-interactive dialog
 *
 *  @param title      title of the dialog
 *  @param message    dialog message content
 *  @param controller presenting controller
 */
+ (void)showInfoDialogWithTitle:(NSString*)title message:(NSString*)message controller:(UIViewController*)controller;

/**
 *  Create a dialog with "yes" and "no" as possible options, where answering
 *  "yes" (default) performs an action, and no dismisses the dialog without
 *  further interaction.
 *
 *  @param title         title of the dialog
 *  @param message       dialog message content
 *  @param controller    presenting controller
 *  @param action        block executed when answer is "yes"
 */
- (instancetype)initBooleanDialogWithTitle:(NSString*)title
                                   message:(NSString*)message
                             defaultsToYes:(BOOL)defaultsToYes
                                    action:(void (^)())action;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

/**
 * Add additional action buttons to the dialog
 * @param title: title of the action button
 * @param style: button style
 * @param block: the block to invoke when button is tapped
 */
- (void)addButtonWithTitle:(NSString*)title style:(HEMAlertViewButtonStyle)style action:(HEMDialogActionBlock)block;

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
 * present this view controller yourself if calling this method.  This controller 
 * will dismiss itself when the default action has been selected.
 *
 * @param controller: the controller that is presenting this dialog
 */
- (void)showFrom:(UIViewController*)controller;

@end
