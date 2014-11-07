//
//  HEMRootViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import <SenseKit/SENAuthorizationService.h>

#import "HEMRootViewController.h"

#import "HEMAlertController.h"
#import "HEMOnboardingUtils.h"
#import "HEMSupportUtil.h"

@interface HEMRootViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) HEMAlertController* supportOptionController;

@end

@implementation HEMRootViewController

#pragma mark - Shake to Show Support Options

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self showSupportOptions];
    }
}

- (void)showSupportOptions {
    if ([self supportOptionController] != nil) return; // don't show it if showing now
    
    // can't simply cache the alertcontroller and not recreate it as the presentingcontroller
    // is cached within it, which may be different each time this is called
    UIViewController* presentingController = [self presentedViewController] ?: self;
    NSString* title = NSLocalizedString(@"support.options.title", nil);
    HEMAlertController* sheet = [[HEMAlertController alloc] initWithTitle:title
                                                                  message:nil
                                                                    style:HEMAlertControllerStyleSheet
                                                     presentingController:presentingController];
    
    [self addContactSupportOptionTo:sheet];
    [self addResetCheckpointOptionTo:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet]; // need to hold on to it otherwise action callbacks will crash
    [[self supportOptionController] show];
}

- (void)addContactSupportOptionTo:(HEMAlertController*)sheet {
    UIViewController* presentingController = [self presentedViewController] ?: self;
    
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"support.option.contact-support", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [HEMSupportUtil contactSupportFrom:presentingController mailDelegate:strongSelf];
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

- (void)addResetCheckpointOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"support.option.reset", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([[strongSelf presentedViewController] isKindOfClass:[UINavigationController class]]) {
                UINavigationController* onboardingVC = (UINavigationController*)[strongSelf presentedViewController];
                UIViewController* startController = [HEMOnboardingUtils onboardingControllerForCheckpoint:HEMOnboardingCheckpointStart authorized:NO];
                if (![[onboardingVC topViewController] isKindOfClass:[startController class]]) {
                    [onboardingVC setViewControllers:@[startController] animated:YES];
                }
            }
            [strongSelf setSupportOptionController:nil];
            [SENAuthorizationService deauthorize];
        }
    }];
}

- (void)addCancelOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"actions.cancel", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

#pragma mark Support Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
