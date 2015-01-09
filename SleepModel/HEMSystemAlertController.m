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

@interface HEMSystemAlertController()<HEMWiFiConfigurationDelegate, HEMPillPairDelegate>

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
        case SENServiceDeviceStateNotConnectedToWiFi:
            *warningTitle = NSLocalizedString(@"alerts.device.sense-wifi.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.no-wifi", nil);
            break;
// don't support this for now since the app currently will never be in this state
//        case SENServiceDeviceStateSenseNotPaired:
//            *warningTitle = NSLocalizedString(@"alerts.device.no-sense.title", nil);
//            *warningMessage = NSLocalizedString(@"alerts.device.no-sense.message", nil);
//            break;
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
        // TODO (jimmy): what is later?
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
        case SENServiceDeviceStateNotConnectedToWiFi:
            [self configureWiFi];
            break;
        case SENServiceDeviceStatePillNotPaired:
            [self showPillPairController];
            break;
        default:
            break;
    }
}

- (void)dismissAlert:(void(^)(void))completion {
    [[self alertView] dismiss:YES completion:^{
        [self setAlertView:nil];
        [self setWarningState:SENServiceDeviceStateUnknown];
        if (completion) completion ();
    }];
}

#pragma mark - WiFi Problems

- (void)configureWiFi {
    HEMWifiPickerViewController* picker =
        (HEMWifiPickerViewController*) [HEMOnboardingStoryboard instantiateWifiPickerViewController];
    [picker setDelegate:self];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:picker];
    [[self viewController] presentViewController:nav animated:YES completion:nil];
}

#pragma mark HEMWifiConfigurationDelegate

- (void)didCancelWiFiConfigurationFrom:(id)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)didConfigureWiFiTo:(NSString *)ssid from:(id)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Pill Problems

- (void)showPillPairController {
    HEMPillPairViewController* pairVC =
    (HEMPillPairViewController*) [HEMOnboardingStoryboard instantiatePillPairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:pairVC];
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
