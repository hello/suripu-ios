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
#import "HEMActionSheetViewController.h"
#import "HEMSupportUtil.h"
#import "HEMOnboardingUtils.h"
#import "HEMOnboardingCache.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"

@interface HEMDebugController()<MFMailComposeViewControllerDelegate>

@property (weak,   nonatomic) UIViewController*   presentingController;
@property (strong, nonatomic) HEMActionSheetViewController* supportOptionController;
@property (strong, nonatomic) HEMActionSheetViewController* ledOptionController;
@property (weak,   nonatomic) UIViewController* roomCheckViewController;
@property (assign, nonatomic) UIModalPresentationStyle origPresentationStyle;

@end

@implementation HEMDebugController

+ (BOOL)isEnabled {
    return YES; // need to create a pre-processor flag to return here
}

- (id)initWithViewController:(UIViewController*)controller {
    self = [super init];
    if (self) {
        [self setPresentingController:[controller presentedViewController] ?: controller];
        [self setOrigPresentationStyle:[[self presentingController] modalPresentationStyle]];
    }
    return self;
}

- (void)setSupportOptionController:(HEMActionSheetViewController *)supportOptionController {
    _supportOptionController = supportOptionController;
    if (_supportOptionController == nil) {
        [[self presentingController] setModalPresentationStyle:[self origPresentationStyle]];
    }
}

- (void)presentOptions:(HEMActionSheetViewController*)optionsVC {
    [optionsVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    if (![[self presentingController] respondsToSelector:@selector(presentationController)]) {
        [[self presentingController] setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
    [[self presentingController] presentViewController:optionsVC animated:YES completion:nil];
}

- (void)showSupportOptions {
    if ([self supportOptionController] != nil) return; // don't show it if showing now

    HEMActionSheetViewController* sheet =
        [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setTitle:NSLocalizedString(@"debug.options.title", nil)];
    
    [self addContactSupportOptionTo:sheet];
    [self addResetCheckpointOptionTo:sheet];
    [self addLedOptionTo:sheet];
    [self addRoomCheckOptionTo:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet];
    
    [sheet addDismissAction:^{
        [self setSupportOptionController:nil];
    }];
    
    [self presentOptions:sheet];
}

- (void)addContactSupportOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.contact-support", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [HEMSupportUtil contactSupportFrom:[strongSelf presentingController]
                              mailDelegate:strongSelf];
        [strongSelf setSupportOptionController:nil];
    }];
}

- (void)addResetCheckpointOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.reset", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([[strongSelf presentingController] isKindOfClass:[UINavigationController class]]) {
            UINavigationController* onboardingVC = (UINavigationController*)[strongSelf presentingController];
            UIViewController* startController =
            [HEMOnboardingUtils onboardingControllerForCheckpoint:HEMOnboardingCheckpointStart force:YES];
            if (![[onboardingVC topViewController] isKindOfClass:[startController class]]) {
                [onboardingVC setViewControllers:@[startController] animated:YES];
            }
        }
        [strongSelf setSupportOptionController:nil];
        [SENAuthorizationService deauthorize];
    }];
}

#pragma mark LED Support

- (void)addLedOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.led", nil) action:^{
                           __strong typeof(weakSelf) strongSelf = weakSelf;
                           [strongSelf showLEDOptions];
                           [strongSelf setSupportOptionController:nil];
                       }];
}

- (void)showLEDOptions {
    if ([self ledOptionController] != nil) return;
    
    HEMActionSheetViewController* sheet =
        [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setTitle:NSLocalizedString(@"debug.option.led.title", nil)];
    
    [self addLEDOption:SENSenseLEDStateOff to:sheet];
    [self addLEDOption:SENSenseLEDStatePair to:sheet];
    [self addLEDOption:SENSenseLEDStateSuccess to:sheet];
    [self addLEDOption:SENSenseLEDStateActivity to:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet];
    [self setLedOptionController:sheet];
    
    [sheet addDismissAction:^{
        [self setSupportOptionController:nil];
        [self setLedOptionController:nil];
    }];
    
    [self presentOptions:sheet];
}

- (void)addLEDOption:(SENSenseLEDState)ledState to:(HEMActionSheetViewController*)sheet {
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
    [sheet addOptionWithTitle:buttonText action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setLedOptionController:nil];
        [strongSelf setSupportOptionController:nil];
        
        if ([[HEMOnboardingCache sharedCache] senseManager] != nil) {
            [[[HEMOnboardingCache sharedCache] senseManager] setLED:ledState completion:nil];
        } else {
            [[SENServiceDevice sharedService] setLEDState:ledState completion:nil];
        }
    }];
}

#pragma mark Room Check

- (void)addRoomCheckOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.room-check.title", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showRoomCheckController];
        [strongSelf setSupportOptionController:nil];
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

- (void)addCancelOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"actions.cancel", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setSupportOptionController:nil];
        [strongSelf setLedOptionController:nil];
    }];
}

#pragma mark Support Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
