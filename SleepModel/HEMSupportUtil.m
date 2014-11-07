//
//  HEMSupportUtil.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import "HEMSupportUtil.h"
#import "HEMAlertController.h"
#import "HEMLogUtils.h"

static NSString* const HEMSupportContactEmail = @"beta-logs@hello.is";
static NSString* const HEMSupportContactSubject = @"App Support Request";
static NSString* const HEMSupportLogFileName = @"newest_log_file.log";
static NSString* const HEMSupportLogFileType = @"text/plain";

@implementation HEMSupportUtil

+ (void)contactSupportFrom:(UIViewController*)controller mailDelegate:(id<MFMailComposeViewControllerDelegate>)delegate {
    if (![MFMailComposeViewController canSendMail]) {
        [HEMAlertController presentInfoAlertWithTitle:NSLocalizedString(@"settings.support.fail.title", nil)
                                              message:NSLocalizedString(@"settings.support.fail.message", nil)
                                 presentingController:controller];
        return;
    }
    MFMailComposeViewController* composer = [[MFMailComposeViewController alloc] init];
    [composer setToRecipients:@[ HEMSupportContactEmail ]];
    [composer setSubject:HEMSupportContactSubject];
    [composer addAttachmentData:[HEMLogUtils latestLogFileData]
                         mimeType:HEMSupportLogFileName
                         fileName:HEMSupportLogFileType];
    composer.mailComposeDelegate = delegate;
    [controller presentViewController:composer animated:YES completion:NULL];
}

@end
