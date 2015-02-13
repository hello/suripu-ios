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

+ (void)openHelpToPage:(NSString*)page fromController:(UIViewController*)controller {
    if ([page length] == 0) {
        return [self openHelpFrom:controller];
    }
    
    NSString* helpURLString = NSLocalizedString(@"help.url.support", nil);
    NSString* url = [helpURLString stringByAppendingPathComponent:page];
    [self openURL:url from:controller];
}

+ (void)openURL:(NSString*)urlString from:(UIViewController*)controller {
    SVModalWebViewController *webViewController =
        [[SVModalWebViewController alloc] initWithAddress:urlString];

    UINavigationBar* navBar = [webViewController navigationBar];
    [navBar setBarTintColor:[HelloStyleKit backViewTintColor]];
    [navBar setTranslucent:NO];
    // show default shadow / divider
    [navBar setClipsToBounds:NO];
    [navBar setShadowImage:nil];
    
    UIToolbar* toolBar = [webViewController toolbar];
    [toolBar setTintColor:[HelloStyleKit senseBlueColor]];
    [toolBar setTranslucent:NO];
    
    [controller presentViewController:webViewController animated:YES completion:nil];
}

@end
