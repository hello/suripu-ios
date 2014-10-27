//
//  HEMAlertUtils.h
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMAlertControllerStyle) {
    HEMAlertControllerStyleAlert,
    HEMAlertControllerStyleSheet,
};

@interface HEMAlertController : NSObject

/**
 *  Present an alert with a single action "Ok"
 *
 *  @param title      Title of the alert
 *  @param message    Alert message text
 *  @param controller controller from which to present the alert
 */
+ (void)presentInfoAlertWithTitle:(NSString*)title
                          message:(NSString*)message
             presentingController:(UIViewController*)controller;

/**
 *  Create a new alert controller
 *
 *  @param title      Title of the alert
 *  @param message    Alert message text
 *  @param style      A presentation style, either as an alert view or action sheet
 *  @param controller controller from which to present the alert
 *
 *  @return new controller
 */
- (instancetype)initWithTitle:(NSString*)title
                      message:(NSString*)message
                        style:(HEMAlertControllerStyle)style
         presentingController:(UIViewController*)controller;

/**
 *  Adds a button with an action to an alert controller
 *
 *  @param text  button text
 *  @param block block to execute when the button is pressed
 */
- (void)addActionWithText:(NSString*)text block:(void (^)())block;

/**
 *  Show the alert controller
 */
- (void)show;

/**
 *  Whether to use `UIAlertController` when presenting an alert
 *
 *  @return YES if the UIAlertController class is accessible and a presenting controller is provided
 */
- (BOOL)shouldUseUIAlertController;

@end