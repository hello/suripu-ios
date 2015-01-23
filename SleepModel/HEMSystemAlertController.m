//
//  HEMSystemAlertController.m
//  Sense
//
//  Created by Jimmy Lu on 12/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENAuthorizationService.h>

#import "UIFont+HEMStyle.h"

#import "HEMSystemAlertController.h"
#import "HEMActionView.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingUtils.h"
#import "HEMWifiPickerViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSupportUtil.h"
#import "HEMPillPairViewController.h"
#import "HEMSensePairViewController.h"
#import "HEMStyledNavigationViewController.h"

@interface HEMSystemAlertController()<HEMPillPairDelegate, HEMSensePairingDelegate>

@property (nonatomic, strong) HEMActionView* alertView;
@property (nonatomic, weak)   UIViewController* viewController;
@property (nonatomic, assign) SENServiceDeviceState warningState;

@end

@implementation HEMSystemAlertController

- (instancetype)initWithViewController:(UIViewController*)viewController {
    self = [super init];
    if (self) {
        [self setViewController:viewController];
        [self listenForSignOut];
    }
    return self;
}

- (void)enableDeviceMonitoring:(BOOL)enable {
    // if already in current state, ignore
    if ([[SENServiceDevice sharedService] monitorDeviceStates] == enable) return;
    
    [[SENServiceDevice sharedService] setMonitorDeviceStates:enable];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    if (enable) {
        [center addObserver:self
                   selector:@selector(showDeviceWarning)
                       name:SENServiceDeviceNotificationWarning
                     object:nil];
    } else {
        [center removeObserver:self name:SENServiceDeviceNotificationWarning object:nil];
    }
}

- (void)showDeviceWarning {
    if ([self alertView] != nil) {
        SENServiceDevice* service = [SENServiceDevice sharedService];
        DDLogVerbose(@"another device warning (%ld) received, but alert already showing somethig",
                     [service deviceState]);
        return;
    }
    
    NSString* title = nil;
    NSString* message = nil;
    SENServiceDevice* service = [SENServiceDevice sharedService];
    [self setWarningState:[service deviceState]];
    [self deviceWarningTitle:&title message:&message];
    
    if (title != nil && message != nil) {
        [self showDeviceWarning:title message:message];
    }
    
}

- (void)deviceWarningTitle:(NSString**)warningTitle message:(NSString**)warningMessage {
    switch ([self warningState]) {
        case SENServiceDeviceStateSenseNotPaired:
            *warningTitle = NSLocalizedString(@"alerts.device.no-sense.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.no-sense.message", nil);
            break;
        case SENServiceDeviceStatePillNotPaired:
            *warningTitle = NSLocalizedString(@"alerts.device.no-pill.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.no-pill.message", nil);
            break;
        default:
            break;
    }
}

- (void)showDeviceWarning:(NSString*)title message:(NSString*)message {
    NSMutableParagraphStyle* messageStyle
        = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [messageStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary* messageAttributes = @{
        NSFontAttributeName : [UIFont deviceAlertMessageFont],
        NSForegroundColorAttributeName : [HelloStyleKit deviceAlertMessageColor],
        NSParagraphStyleAttributeName : messageStyle};
    
    NSAttributedString* attrMessage = [[NSAttributedString alloc] initWithString:message
                                                                      attributes:messageAttributes];
    HEMActionView* alert = [[HEMActionView alloc] initWithTitle:title message:attrMessage];
    [self setAlertView:alert];
    [[[self alertView] cancelButton] setTitle:[NSLocalizedString(@"actions.later", nil) uppercaseString]
                                     forState:UIControlStateNormal];
    [[[self alertView] cancelButton] addTarget:self
                                        action:@selector(fixDeviceProblemLater:)
                              forControlEvents:UIControlEventTouchUpInside];
    [[[self alertView] okButton] setTitle:[NSLocalizedString(@"actions.fix-now", nil) uppercaseString]
                                 forState:UIControlStateNormal];
    [[[self alertView] okButton] addTarget:self
                                    action:@selector(fixDeviceProblemNow:)
                          forControlEvents:UIControlEventTouchUpInside];
    [[self alertView] showInView:[[self viewController] view] animated:YES completion:nil];
}

- (void)fixDeviceProblemLater:(id)sender {
    [self dismissAlert:^{
        [self setWarningState:SENServiceDeviceStateUnknown];
    }];
}

- (void)fixDeviceProblemNow:(id)sender {
    [self dismissAlert:^{
        [self launchHandlerForDeviceState];
    }];
}

- (void)launchHandlerForDeviceState {
    // supported warnings are handled below
    switch ([self warningState]) {
        case SENServiceDeviceStateSenseNotPaired:
            [self showSensePairController];
            break;
        case SENServiceDeviceStatePillNotPaired:
            [self showPillPairController];
            break;
        default:
            break;
    }
    // reset it
    [self setWarningState:SENServiceDeviceStateUnknown];
}

- (void)dismissAlert:(void(^)(void))completion {
    [[self alertView] dismiss:YES completion:^{
        [self setAlertView:nil];
        if (completion) completion ();
    }];
}

#pragma mark  - Sense Problems

- (void)showSensePairController {
    HEMSensePairViewController* pairVC =
        (HEMSensePairViewController*) [HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [[self viewController] presentViewController:nav animated:YES completion:nil];
}

#pragma mark HEMSensePairDelegate

- (void)didPairSense:(BOOL)pair from:(UIViewController*)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSetupWiFiForPairedSense:(BOOL)setup from:(UIViewController*)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Pill Problems

- (void)showPillPairController {
    HEMPillPairViewController* pairVC =
        (HEMPillPairViewController*) [HEMOnboardingStoryboard instantiatePillPairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [[self viewController] presentViewController:nav animated:YES completion:nil];
}

#pragma mark - HEMPillPairDelegate

- (void)didPairWithPillFrom:(HEMPillPairViewController *)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPairing:(HEMPillPairViewController *)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Sign Outs

- (void)listenForSignOut {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userDidSignOut)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
}

- (void)userDidSignOut {
    [self dismissAlert:nil];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:SENServiceDeviceNotificationWarning object:nil];
    
    [[SENServiceDevice sharedService] setMonitorDeviceStates:NO];
}

#pragma mark - Clean Up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
