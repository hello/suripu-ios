//
//  HEMAlertUtils.h
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HEMActionSheetCallback)(void);

@interface HEMActionSheetViewController : UIViewController

/**
 * @property title
 *
 * @discussion
 * Optional text to be displayed above all the options that are added when the
 * controller is presented.
 */
@property (nonatomic, copy) NSString* title;

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
 * @param optionTitle: title to be displayed for the option
 * @param color:       optional color to be used for the title
 * @param description: optional description to be displayed below the title
 * @param action:      block to be invoked when the option is selected
 */
- (void)addOptionWithTitle:(NSString*)optionTitle
                titleColor:(UIColor*)color
               description:(NSString*)description
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
 * @method show
 *
 * @discussion
 * Show the action sheet
 */
- (void)show;

@end