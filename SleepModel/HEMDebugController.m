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
#import "HEMActionSheetController.h"
#import "HEMSupportUtil.h"
#import "HEMOnboardingUtils.h"
#import "HEMOnboardingCache.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMStyledNavigationViewController.h"

@interface HEMDebugController()<MFMailComposeViewControllerDelegate>

@property (weak,   nonatomic) UIViewController*   presentingController;
@property (strong, nonatomic) HEMActionSheetController* supportOptionController;
@property (strong, nonatomic) HEMActionSheetController* ledOptionController;
@property (weak,   nonatomic) UIViewController* roomCheckViewController;

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
    HEMActionSheetController* sheet = [[HEMActionSheetController alloc] initWithTitle:title
                                                                              message:nil
                                                                 presentingController:[self presentingController]];
    
    [self addContactSupportOptionTo:sheet];
    [self addResetCheckpointOptionTo:sheet];
    [self addLedOptionTo:sheet];
    [self addRoomCheckOptionTo:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet]; // need to hold on to it otherwise action callbacks will crash
    [[self supportOptionController] show];
}

- (void)addContactSupportOptionTo:(HEMActionSheetController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"debug.option.contact-support", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [HEMSupportUtil contactSupportFrom:[strongSelf presentingController] mailDelegate:strongSelf];
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

- (void)addResetCheckpointOptionTo:(HEMActionSheetController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"debug.option.reset", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([[strongSelf presentingController] isKindOfClass:[UINavigationController class]]) {
                UINavigationController* onboardingVC = (UINavigationController*)[strongSelf presentingController];
                UIViewController* startController = [HEMOnboardingUtils onboardingControllerForCheckpoint:HEMOnboardingCheckpointStart force:YES];
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

- (void)addLedOptionTo:(HEMActionSheetController*)sheet {
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
    HEMActionSheetController* sheet = [[HEMActionSheetController alloc] initWithTitle:title
                                                                              message:nil
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

- (void)addLEDOption:(SENSenseLEDState)ledState to:(HEMActionSheetController*)sheet {
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

#pragma mark Room Check

- (void)addRoomCheckOptionTo:(HEMActionSheetController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"debug.option.room-check.title", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf showRoomCheckController];
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

- (void)showRoomCheckController {
    UIViewController* rcVC = [HEMOnboardingStoryboard instantiateRoomCheckViewController];
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:rcVC];
    [[self presentingController] presentViewController:nav animated:YES completion:nil];

    [self setRoomCheckViewController:nav];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEndRoomCheck:)
                                                 name:HEMOnboardingNotificationComplete
                                               object:nil];
}

- (void)didEndRoomCheck:(NSNotification*)notification {
    if ([self roomCheckViewController] != nil) {
        [[self presentingController] dismissViewControllerAnimated:YES completion:nil];
        [self setRoomCheckViewController:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HEMOnboardingNotificationComplete object:nil];
}

#pragma mark Cancel

- (void)addCancelOptionTo:(HEMActionSheetController*)sheet {
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
