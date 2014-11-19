//
//  HEMSupportUtil.h
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import <Foundation/Foundation.h>

@interface HEMSupportUtil : NSObject

/**
 * Launch a mail composer, if email accounts are configured, that attaches sys
 * logs to the email which is addressed to an customer support address.  If an
 * account is not configured
 */
+ (void)contactSupportFrom:(UIViewController*)controller
              mailDelegate:(id<MFMailComposeViewControllerDelegate>)delegate;

/**
 * Opens up a screen that shows help / troubleshooting tips
 * @param controller: the controller to present the new screen
 */
+ (void)openHelpFrom:(UIViewController*)controller;

/**
 * Open a url from the controller specified
 * @param urlString:  a fully qualified http url
 * @param controller: the controller wishing to show this url
 */
+ (void)openURL:(NSString*)urlString from:(UIViewController*)controller;

@end
