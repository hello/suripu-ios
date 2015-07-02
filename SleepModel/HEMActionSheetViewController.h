//
//  HEMAlertUtils.h
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMActionSheetDefaultCellHeight;

typedef void(^HEMActionSheetCallback)(void);

@interface HEMActionSheetViewController : UIViewController

@property (nonatomic, assign, readonly) NSUInteger numberOfOptions;

/**
 * @method addOptionWithTitle:action:
 *
 * @param optionTitle: title to be displayed for the option
 * @param action:      block to be invoked when the option is selected
 */
- (void)addOptionWithTitle:(NSString*)optionTitle action:(HEMActionSheetCallback)action;

/**
 * @method addOptionWithTitle:titleColor:description:action
 *
 * @param optionTitle title to be displayed for the option
 * @param color       optional color to be used for the title
 * @param description optional description to be displayed below the title
 * @param imageName   optional image to display leading the discription
 * @param action      block to be invoked when the option is selected
 */
- (void)addOptionWithTitle:(NSString*)optionTitle
                titleColor:(UIColor*)color
               description:(NSString*)description
                 imageName:(NSString*)imageName
                    action:(HEMActionSheetCallback)action;

/**
 * @method addDismissAction:
 *
 * @discussion
 * If an explicit 'Cancel' action is not added through addOption:..., you can
 * add a handler for when user dismisses the action sheet by interacting with
 * the background.
 */
- (void)addDismissAction:(HEMActionSheetCallback)action;

/**
 * @method addConfirmationView:displayFor:forOptionWithTitle:
 *
 * @discussion
 * Add a confirmation message to be displayed upon selection an option.  The
 * confirmation will be shown for the display time specified, but only after
 * the action block for the option is fired.  This is optional
 *
 * @param confirmationView: the view to be displayed.  The view will be adjusted
 *                          at run time to the size of the actionsheet itself.
 * @param displayTime:      the duration to display the view for
 * @param title:            the option title this confirmation is meant for
 */
- (void)addConfirmationView:(UIView*)confirmationView
                 displayFor:(CGFloat)displayTime
         forOptionWithTitle:(NSString*)title;

/**
 * @method setCustomTitleView:
 *
 * @discussion
 * Instead of using setTitle:, which would display a title above the options that
 * can't be interacted with, you can optionally set a custom view.
 *
 * @param view: the custom view to set / display above the options.  The view will
 *              be automatically resized to fit the controller
 */
- (void)setCustomTitleView:(UIView*)view;

/**
 * @method show
 *
 * @discussion
 * Show the action sheet
 */
- (void)show;

@end
