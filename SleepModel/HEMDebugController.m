//
//  HEMDebugController.m
//  Sense
//
//  Created by Jimmy Lu on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import <SenseKit/API.h>
#import <SenseKit/SENSenseManager.h>

#import "HEMDebugController.h"
#import "HEMActionSheetViewController.h"
#import "HEMSupportUtil.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMMainStoryboard.h"
#import "UIColor+HEMStyle.h"
#import "HEMTutorial.h"
#import "HEMOnboardingController.h"
#import "HEMInfoViewController.h"
#import "HEMDebugInfoDataSource.h"
#import "HEMConfig.h"

@interface HEMDebugController()<MFMailComposeViewControllerDelegate>

@property (weak,   nonatomic) UIViewController*   presentingController;
@property (strong, nonatomic) HEMActionSheetViewController* supportOptionController;
@property (strong, nonatomic) HEMActionSheetViewController* ledOptionController;
@property (weak,   nonatomic) UIViewController* roomCheckViewController;
@property (assign, nonatomic) UIModalPresentationStyle origPresentationStyle;

@end

@implementation HEMDebugController

+ (void)disableDebugMenuIfNeeded {
    if (![self isEnabled]) {
        [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
    }
}

+ (BOOL)isEnabled {
    return [HEMConfig booleanForConfig:HEMConfAllowDebugOptions];
}

- (id)initWithViewController:(UIViewController*)controller {
    self = [super init];
    if (self) {
        [self setPresentingController:controller];
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

- (void)showController:(UIViewController*)controller
              animated:(BOOL)animated
            completion:(void (^)(void))completion{
    
    UIViewController* parent = [self presentingController];
    while ([parent presentedViewController]) {
        parent = [parent presentedViewController];
    }
    [parent presentViewController:controller animated:animated completion:completion];
}

- (void)showSupportOptions {
    if ([self supportOptionController] != nil) return; // don't show it if showing now

    HEMActionSheetViewController* sheet =
        [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setTitle:NSLocalizedString(@"debug.options.title", nil)];
    
    [self addContactSupportOptionTo:sheet];
    [self addLedOptionTo:sheet];
    [self addRoomCheckOptionTo:sheet];
    [self addResetTutorialsOptionTo:sheet];
    [self addDebugInfoOptionTo:sheet];
    [self addChangeServerOptionToSheet:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet];
    
    [sheet addDismissAction:^{
        [self setSupportOptionController:nil];
    }];
    
    [self showController:sheet animated:NO completion:nil];
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

- (void)addDebugInfoOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.debug.info", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showDebugInfo];
        [strongSelf setSupportOptionController:nil];
    }];
}

- (void)addChangeServerOptionToSheet:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.change-api-address", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showURLUpdateAlertView];
        [strongSelf setSupportOptionController:nil];
    }];
}

#pragma mark Debug Info

- (void)showDebugInfo {
    UINavigationController* navVC = [HEMMainStoryboard instantiateInfoNavigationController];
    HEMInfoViewController* infoVC = (id)[navVC topViewController];
    [infoVC setTitle:NSLocalizedString(@"debug.option.debug.info", nil)];
    
    HEMDebugInfoDataSource* source = [[HEMDebugInfoDataSource alloc] init];
    [infoVC setInfoSource:source];
    
    [self showController:navVC animated:YES completion:nil];
}

#pragma mark API Address

- (void)showURLUpdateAlertView {
    UIAlertView* URLAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.set-url.title", nil)
                                                           message:NSLocalizedString(@"authorization.set-url.message", nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                                                 otherButtonTitles:NSLocalizedString(@"actions.save", nil), NSLocalizedString(@"authorization.set-url.action.reset", nil), nil];
    URLAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* URLField = [URLAlertView textFieldAtIndex:0];
    URLField.text = [SENAPIClient baseURL].absoluteString;
    URLField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [URLAlertView show];
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 2: {
            [SENAPIClient resetToDefaultBaseURL];
            break;
        }
        case 1: {
            UITextField* URLField = [alertView textFieldAtIndex:0];
            if (![SENAPIClient setBaseURLFromPath:URLField.text]) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.failed-url.title", nil)
                                            message:NSLocalizedString(@"authorization.failed-url.message", nil)
                                           delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                                  otherButtonTitles:nil] show];
            }
            break;
        }
    }
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
    
    [self showController:sheet animated:NO completion:nil];
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
        [[[HEMOnboardingService sharedService] currentSenseManager] setLED:ledState completion:nil];
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
    [self showController:nav animated:YES completion:nil];

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

#pragma mark Tutorials

- (void)addResetTutorialsOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.reset-tutorials", nil) action:^{
        [HEMTutorial resetTutorials];
        [weakSelf setSupportOptionController:nil];
    }];
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
