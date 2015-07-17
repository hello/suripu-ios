//
//  HEMSupportUtil.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import <sys/sysctl.h>

#import <SVWebViewController/SVModalWebViewController.h>

#import <SenseKit/SENServiceAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMSupportUtil.h"
#import "HEMAlertViewController.h"
#import "HEMLogUtils.h"
#import "UIColor+HEMStyle.h"

static NSString* const HEMSupportContactEmail = @"beta-logs@hello.is";
static NSString* const HEMSupportContactSubject = @"App Support Request";
static NSString* const HEMSupportLogFileName = @"newest_log_file.log";
static NSString* const HEMSupportLogFileType = @"text/plain";

@implementation HEMSupportUtil

+ (NSString*)deviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char* result = malloc(size);
    sysctlbyname("hw.machine", result, &size, NULL, 0);
    
    NSString* deviceModel = [NSString stringWithUTF8String:result];
    free(result);
    
    return deviceModel;
}

+ (NSString*)emailMessageBody {
    UIDevice* device = [UIDevice currentDevice];
    NSBundle* bundle = [NSBundle mainBundle];
    
    NSString* appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString* appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString* osVersion = [device systemVersion];
    NSString* deviceModel = [self deviceModel]; // this is used over UIDevice as it gives the model number
    NSString* accountEmail = [[[SENServiceAccount sharedService] account] email];
    
    if (accountEmail) {
        return [NSString stringWithFormat:@"\n\n\n\n\n-----------------\n%@ v%@\nAccount %@\n%@\nOS %@",
                appName, appVersion, accountEmail, deviceModel, osVersion];
    } else {
        return [NSString stringWithFormat:@"\n\n\n\n\n-----------------\n%@ v%@\n%@\nOS %@",
                appName, appVersion, deviceModel, osVersion];
    }
}

+ (void)sendEmailTo:(NSString*)email
        withSubject:(NSString*)subject
          attachLog:(BOOL)attachLog
               from:(UIViewController*)controller
       mailDelegate:(id<MFMailComposeViewControllerDelegate>)delegate {
    
    if (![MFMailComposeViewController canSendMail]) {
        [HEMAlertViewController showInfoDialogWithTitle:NSLocalizedString(@"settings.support.fail.title", nil)
                                                message:NSLocalizedString(@"settings.support.fail.message", nil)
                                             controller:controller];
        return;
    }
    
    MFMailComposeViewController* composer = [[MFMailComposeViewController alloc] init];
    [composer setToRecipients:@[ email ]];
    [composer setSubject:subject];
    [composer setMessageBody:[self emailMessageBody] isHTML:NO];
    
    if (attachLog) {
        [composer addAttachmentData:[HEMLogUtils latestLogFileData]
                           mimeType:HEMSupportLogFileType
                           fileName:HEMSupportLogFileName];
    }
    
    composer.mailComposeDelegate = delegate;
    [controller presentViewController:composer animated:YES completion:NULL];
    
}

+ (void)contactSupportFrom:(UIViewController*)controller
              mailDelegate:(id<MFMailComposeViewControllerDelegate>)delegate {
    
    [self sendEmailTo:HEMSupportContactEmail
          withSubject:HEMSupportContactSubject
            attachLog:YES
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
    [navBar setBarTintColor:[UIColor backViewTintColor]];
    [navBar setTranslucent:NO];
    // show default shadow / divider
    [navBar setClipsToBounds:NO];
    [navBar setShadowImage:nil];
    
    UIToolbar* toolBar = [webViewController toolbar];
    [toolBar setTintColor:[UIColor senseBlueColor]];
    [toolBar setTranslucent:NO];
    
    [controller presentViewController:webViewController animated:YES completion:nil];
}

@end
