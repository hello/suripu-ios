//
//  HEMAlertUtils.h
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMActionSheetController : NSObject

/**
 *  Create a new action sheet controller
 *
 *  @param title      title
 *  @param message    message text
 *  @param controller controller from which to present the sheet
 *
 *  @return new controller
 */
- (instancetype)initWithTitle:(NSString*)title
                      message:(NSString*)message
         presentingController:(UIViewController*)controller;

/**
 *  Adds a button with an action
 *
 *  @param text  button text
 *  @param block block to execute when the button is pressed
 */
- (void)addActionWithText:(NSString*)text block:(void (^)())block;

/**
 *  Show the sheet controller
 */
- (void)show;

@end
