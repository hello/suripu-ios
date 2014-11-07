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

@end