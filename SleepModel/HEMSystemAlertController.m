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
#import "HEMRootViewController.h"
#import "HEMDevicesViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMSystemAlertController()<HEMPillPairDelegate, HEMSensePairingDelegate>

@property (nonatomic, strong) HEMActionView* alertView;
@property (nonatomic, weak)   UIViewController* viewController;
@property (nonatomic, assign) SENServiceDeviceState warningState;
@property (nonatomic, assign) BOOL enableDeviceMonitoring;

@end

@implementation HEMSystemAlertController

- (instancetype)initWithViewController:(UIViewController*)viewController {
    self = [super init];
    if (self) {
        [self setViewController:viewController];
    }
    return self;
}

- (void)enableDeviceMonitoring:(BOOL)enable {
    _enableDeviceMonitoring = enable;
    
    if (enable) {
        [self checkDevicesIfEnabled];
    } else {
        [[SENServiceDevice sharedService] resetDeviceStates];
    }

}

- (void)checkDevicesIfEnabled {
    if ([self enableDeviceMonitoring]) {
        __weak typeof(self) weakSelf = self;
        [[SENServiceDevice sharedService] checkDevicesState:^(SENServiceDeviceState state) {
            if (state != SENServiceDeviceStateUnknown && state != SENServiceDeviceStateNormal) {
                [weakSelf showDeviceWarning];
            }
        }];
    }
}

- (void)showDeviceWarning {
    if ([self alertView] != nil) {
        SENServiceDevice* service = [SENServiceDevice sharedService];
        DDLogVerbose(@"another alert is currently shown, skip showing %ld",
                     [service deviceState]);
        return;
    }
    
    NSString* title = nil;
    NSString* message = nil;
    NSString* cancelTitle = nil;
    NSString* fixTitle = nil;
    
    SENServiceDevice* service = [SENServiceDevice sharedService];
    [self setWarningState:[service deviceState]];
    [self deviceWarningTitle:&title message:&message cancelButtonTitle:&cancelTitle fixButtonTitle:&fixTitle];
    
    if ( message != nil) { // title is optional, but if message its nil, then we assume warning is not supported
        [self showDeviceWarningWithTitle:title message:message cancelButtonTitle:cancelTitle fixButtonTitle:fixTitle];
        [SENAnalytics track:HEMAnalyticsEventSystemAlert
                 properties:@{kHEMAnalyticsEventPropType : @([service deviceState])}];
    }
    
}

- (void)deviceWarningTitle:(NSString**)warningTitle
                   message:(NSString**)warningMessage
         cancelButtonTitle:(NSString**)cancelTitle
            fixButtonTitle:(NSString**)fixTitle {
    
    switch ([self warningState]) {
        case SENServiceDeviceStateSenseNotPaired:
            *warningTitle = NSLocalizedString(@"alerts.device.no-sense.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.no-sense.message", nil);
            break;
        case SENServiceDeviceStateSenseNotSeen:
            *warningTitle = NSLocalizedString(@"alerts.device.sense-last-seen.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.sense-last-seen.message", nil);
            break;
        case SENServiceDeviceStatePillNotPaired:
            *warningTitle = NSLocalizedString(@"alerts.device.no-pill.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.no-pill.message", nil);
            break;
        case SENServiceDeviceStatePillNotSeen:
            *warningTitle = NSLocalizedString(@"alerts.device.pill-last-seen.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.pill-last-seen.message", nil);
            break;
        case SENServiceDeviceStatePillLowBattery:
            *warningMessage = NSLocalizedString(@"alerts.device.pill-low-battery.message", nil);
            *cancelTitle = NSLocalizedString(@"actions.skip", nil);
            *fixTitle = NSLocalizedString(@"actions.order-new", nil);
        default:
            break;
    }
    
    if (*warningMessage != nil) {
        if (*cancelTitle == nil) {
            *cancelTitle = NSLocalizedString(@"actions.later", nil);
        }
        
        if (*fixTitle == nil) {
            *fixTitle = NSLocalizedString(@"actions.fix-now", nil);
        }
    }

}

- (void)showDeviceWarningWithTitle:(NSString*)title message:(NSString*)message
                 cancelButtonTitle:(NSString*)cancelTitle fixButtonTitle:(NSString*)fixTitle {
    
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
    [[[self alertView] cancelButton] setTitle:[cancelTitle uppercaseString]
                                     forState:UIControlStateNormal];
    [[[self alertView] cancelButton] addTarget:self
                                        action:@selector(fixDeviceProblemLater:)
                              forControlEvents:UIControlEventTouchUpInside];
    [[[self alertView] okButton] setTitle:[fixTitle uppercaseString]
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
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionLater}];
}

- (void)fixDeviceProblemNow:(id)sender {
    [self dismissAlert:^{
        [self launchHandlerForDeviceState];
    }];
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionNow}];
}

- (void)launchHandlerForDeviceState {
    // supported warnings are handled below
    switch ([self warningState]) {
        case SENServiceDeviceStateSenseNotPaired:
            [self showSensePairController];
            break;
        case SENServiceDeviceStateSenseNotSeen:
            [self showSenseHelp];
            break;
        case SENServiceDeviceStatePillNotPaired:
            [self showPillPairController];
            break;
        case SENServiceDeviceStatePillNotSeen:
            [self showPillHelp];
            break;
        case SENServiceDeviceStatePillLowBattery:
            [self showHowToReplacePillBattery];
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

- (void)showSenseHelp {
    NSString* senseHelpSlug = NSLocalizedString(@"help.url.slug.sense-not-seen", nil);
    [HEMSupportUtil openHelpToPage:senseHelpSlug fromController:[self viewController]];
}

#pragma mark HEMSensePairDelegate

- (void)cacheSenseManager:(SENSenseManager*)senseManager {
    if (senseManager != nil) {
        SENServiceDevice* service = [SENServiceDevice sharedService];
        [service replaceWithNewlyPairedSenseManager:senseManager completion:nil];
    }
}

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [self cacheSenseManager:senseManager];
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [self cacheSenseManager:senseManager];
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

- (void)showPillHelp {
    NSString* pillHelpSlug = NSLocalizedString(@"help.url.slug.pill-not-seen", nil);
    [HEMSupportUtil openHelpToPage:pillHelpSlug fromController:[self viewController]];
}

- (void)showHowToReplacePillBattery {
    NSString* page = NSLocalizedString(@"help.url.slug.pill-battery", nil);
    [HEMSupportUtil openHelpToPage:page fromController:[self viewController]];
}

#pragma mark - HEMPillPairDelegate

- (void)didPairWithPillFrom:(HEMPillPairViewController *)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPairing:(HEMPillPairViewController *)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Auth Changes

- (void)listenForAuthChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userDidSignOut)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
}

- (void)userDidSignOut {
    [self dismissAlert:nil];
    [self setEnableDeviceMonitoring:NO];
}

#pragma mark - Clean Up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
