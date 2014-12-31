//
//  HEMDebugController.m
//  Sense
//
//  Created by Jimmy Lu on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceDevice.h>

#import "HEMDebugController.h"
#import "HEMAlertController.h"
#import "HEMSupportUtil.h"
#import "HEMOnboardingUtils.h"
#import "HEMOnboardingCache.h"

@interface HEMDebugController()<MFMailComposeViewControllerDelegate>

@property (weak,   nonatomic) UIViewController*   presentingController;
@property (strong, nonatomic) HEMAlertController* supportOptionController;
@property (strong, nonatomic) HEMAlertController* ledOptionController;

@end

@implementation HEMDebugController

+ (BOOL)isEnabled {
    return YES; // need to create a pre-processor flag to return here
}

- (id)initWithViewController:(UIViewController*)controller {
    self = [super init];
    if (self) {
        [self setPresentingController:[controller presentedViewController] ?: controller];
    }
    return self;
}

- (void)showSupportOptions {
    if ([self supportOptionController] != nil) return; // don't show it if showing now

    NSString* title = NSLocalizedString(@"debug.options.title", nil);
    HEMAlertController* sheet = [[HEMAlertController alloc] initWithTitle:title
                                                                  message:nil
                                                                    style:HEMAlertControllerStyleSheet
                                                     presentingController:[self presentingController]];
    
    [self addContactSupportOptionTo:sheet];
    [self addResetCheckpointOptionTo:sheet];
    [self addLedOptionTo:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet]; // need to hold on to it otherwise action callbacks will crash
    [[self supportOptionController] show];
}

- (void)addContactSupportOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"debug.option.contact-support", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [HEMSupportUtil contactSupportFrom:[strongSelf presentingController] mailDelegate:strongSelf];
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

- (void)addResetCheckpointOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"debug.option.reset", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([[strongSelf presentingController] isKindOfClass:[UINavigationController class]]) {
                UINavigationController* onboardingVC = (UINavigationController*)[strongSelf presentingController];
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

#pragma mark LED Support

- (void)addLedOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"debug.option.led", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf showLEDOptions];
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

- (void)showLEDOptions {
    if ([self ledOptionController] != nil) return;
    
    NSString* title = NSLocalizedString(@"debug.option.led.title", nil);
    HEMAlertController* sheet = [[HEMAlertController alloc] initWithTitle:title
                                                                  message:nil
                                                                    style:HEMAlertControllerStyleSheet
                                                     presentingController:[self presentingController]];
    [self addLEDOption:SENSenseLEDStateOff to:sheet];
    [self addLEDOption:SENSenseLEDStatePair to:sheet];
    [self addLEDOption:SENSenseLEDStateSuccess to:sheet];
    [self addLEDOption:SENSenseLEDStateActivity to:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet];
    [self setLedOptionController:sheet];
    [[self ledOptionController] show];
}

- (void)addLEDOption:(SENSenseLEDState)ledState to:(HEMAlertController*)sheet {
    NSString* buttonText = nil;
    switch (ledState) {
        case SENSenseLEDStatePair:
            buttonText = NSLocalizedString(@"debug.led.option.pair", nil);
            break;
        case SENSenseLEDStateActivity:
            buttonText = NSLocalizedString(@"debug.led.option.activity", nil);
            break;
        case SENSenseLEDStateSuccess:
            buttonText = NSLocalizedString(@"debug.led.option.success", nil);
            break;
        case SENSenseLEDStateOff:
        default:
            buttonText = NSLocalizedString(@"debug.led.option.off", nil);
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:buttonText block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setLedOptionController:nil];
        }
        
        if ([[HEMOnboardingCache sharedCache] senseManager] != nil) {
            [[[HEMOnboardingCache sharedCache] senseManager] setLED:ledState completion:nil];
        } else {
            [[SENServiceDevice sharedService] setLEDState:ledState completion:nil];
        }
        
    }];
}

#pragma mark Cancel

- (void)addCancelOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"actions.cancel", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setSupportOptionController:nil];
            [strongSelf setLedOptionController:nil];
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
