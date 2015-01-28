//
//  HEMDialogViewController.h
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMDialogView.h"

@interface HEMDialogViewController : UIViewController

// properties should be set prior to showing the dialog
@property (nonatomic, weak)   UIView* viewToShowThrough;
@property (nonatomic, strong) UIImage* dialogImage;
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, copy)   NSString* message;
@property (nonatomic, copy)   NSString* okButtonTitle;
@property (nonatomic, assign) BOOL showHelp;

/**
 * Add additional action buttons to the dialog
 * @param title:   title of the action button
 * @param primary: YES if primary action, NO otherwise
 * @param block:   the block to invoke when button is tapped
 */
- (void)addAction:(NSString*)title primary:(BOOL)primary actionBlock:(HEMDialogActionBlock)block;

/**
 * Call this method to show the actual dialog, which will present itself.  Do not
 * present this view controller yourself if calling this method
 *
 * @param controller: the controller that is presenting this dialog
 * @param doneBlock:  the block to invoke when user taps on Okay button
 */
- (void)showFrom:(UIViewController*)controller onDone:(HEMDialogActionBlock)doneBlock;

/**
 * Call this method if you are presenting this controller yourself, which will
 * show the dialog.  If using this method, call it after you have presented the
 * controller for optimal experience
 *
 * @param doneBlock:  the block to invoke when user taps on Okay button
 */
- (void)show:(HEMDialogActionBlock)doneBlock;

@end
