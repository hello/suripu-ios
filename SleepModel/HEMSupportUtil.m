//
//  HEMSupportUtil.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import <SVWebViewController/SVModalWebViewController.h>

#import "UIFont+HEMStyle.h"

#import "HEMSupportUtil.h"
#import "HEMAlertController.h"
#import "HEMLogUtils.h"
#import "HelloStyleKit.h"

static NSString* const HEMSupportContactEmail = @"beta-logs@hello.is";
static NSString* const HEMSupportContactSubject = @"App Support Request";
static NSString* const HEMSupportLogFileName = @"newest_log_file.log";
static NSString* const HEMSupportLogFileType = @"text/plain";

@implementation HEMSupportUtil

+ (void)sendEmailTo:(NSString*)email
        withSubject:(NSString*)subject
               from:(UIViewController*)controller
       mailDelegate:(id<MFMailComposeViewControllerDelegate>)delegate {
    
    if (![MFMailComposeViewController canSendMail]) {
        [HEMAlertController presentInfoAlertWithTitle:NSLocalizedString(@"settings.support.fail.title", nil)
                                              message:NSLocalizedString(@"settings.support.fail.message", nil)
                                 presentingController:controller];
        return;
    }
    
    MFMailComposeViewController* composer = [[MFMailComposeViewController alloc] init];
    [composer setToRecipients:@[ email ]];
    [composer setSubject:subject];
    [composer addAttachmentData:[HEMLogUtils latestLogFileData]
                       mimeType:HEMSupportLogFileType
                       fileName:HEMSupportLogFileName];
    composer.mailComposeDelegate = delegate;
    [controller presentViewController:composer animated:YES completion:NULL];
    
}

+ (void)contactSupportFrom:(UIViewController*)controller
              mailDelegate:(id<MFMailComposeViewControllerDelegate>)delegate {
    
    [self sendEmailTo:HEMSupportContactEmail
          withSubject:HEMSupportContactSubject
                 from:controller
         mailDelegate:delegate];
}

+ (void)openOrderFormFrom:(UIViewController*)controller {
    NSString* orderURLString = NSLocalizedString(@"help.url.order-form", nil);
    [self openURL:orderURLString from:controller];
}

+ (void)openHelpFrom:(UIViewController*)controller {
    NSString* helpURLString = NSLocalizedString(@"help.url.support", nil);
    [self openURL:helpURLString from:controller];
}

+ (void)openURL:(NSString*)urlString from:(UIViewController*)controller {
    SVModalWebViewController *webViewController =
        [[SVModalWebViewController alloc] initWithAddress:urlString];
    
    UIColor* barColor = [UIColor whiteColor];
    [[webViewController navigationBar] setBackgroundColor:barColor];
    [[webViewController toolbar] setBackgroundColor:barColor];
    [[webViewController navigationBar] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor],
        NSFontAttributeName : [UIFont inAppBrowserTitleFont]
    }];
    
    [controller presentViewController:webViewController animated:YES completion:nil];
}

@end
