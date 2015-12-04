//
//  HEMSystemAlertController.m
//  Sense
//
//  Created by Jimmy Lu on 12/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPITimeZone.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMSystemAlertController.h"
#import "HEMActionView.h"
#import "HEMWifiPickerViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSupportUtil.h"
#import "HEMPillPairViewController.h"
#import "HEMSensePairViewController.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMRootViewController.h"
#import "HEMDevicesViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMBounceModalTransition.h"
#import "HEMAppUsage.h"

typedef NS_ENUM(NSUInteger, HEMSystemAlertType) {
    HEMSystemAlertTypeUnknown = 0,
    HEMSystemAlertTypeNoInternet = 1,
    HEMSystemAlertTypeNoTimeZone = 2,
    HEMSystemAlertTypeNoSensePaired = 3,
    HEMSystemAlertTypeNoPillPaired = 4,
    HEMSystemAlertTypeSenseNotSeen = 5,
    HEMSystemAlertTypePillNotSeen = 6,
    HEMSystemAlertTypePillLowBattery = 7
};

@interface HEMSystemAlertController()<HEMPillPairDelegate, HEMSensePairingDelegate>

@property (nonatomic, strong) HEMActionView* alertView;
@property (nonatomic, weak)   UIViewController* viewController;
@property (nonatomic, assign) BOOL enableSystemMonitoring;
@property (nonatomic, strong) HEMBounceModalTransition* modalTransitionDelegate;

@end

@implementation HEMSystemAlertController

- (instancetype)initWithViewController:(UIViewController*)viewController {
    self = [super init];
    if (self) {
        [self setViewController:viewController];
    }
    return self;
}

- (void)enableSystemMonitoring:(BOOL)enable {
    _enableSystemMonitoring = enable;
    
    if (enable) {
        [self checkSystemIfEnabled];
    } else {
        [self stopListeningForInternetConnectivityChanges];
        [[SENServiceDevice sharedService] resetDeviceStates];
    }

}

- (HEMActionView*)configureAlertViewWithTitle:(NSString*)title
                                      message:(NSString*)message
                            cancelButtonTitle:(NSString*)cancelTitle
                               fixButtonTitle:(NSString*)fixTitle {
    
    NSMutableParagraphStyle* messageStyle
    = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [messageStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary* messageAttributes = @{
                                        NSFontAttributeName : [UIFont systemAlertMessageFont],
                                        NSForegroundColorAttributeName : [UIColor deviceAlertMessageColor],
                                        NSParagraphStyleAttributeName : messageStyle};
    
    NSAttributedString* attrMessage = [[NSAttributedString alloc] initWithString:message
                                                                      attributes:messageAttributes];
    HEMActionView* alert = [[HEMActionView alloc] initWithTitle:title message:attrMessage];
    [[alert cancelButton] setTitle:[cancelTitle uppercaseString] forState:UIControlStateNormal];
    
    if (fixTitle) {
        [[alert okButton] setTitle:[fixTitle uppercaseString] forState:UIControlStateNormal];
    } else {
        [alert hideOkButton];
    }
    
    return alert;
}

- (void)cancelAlert:(id)sender {
    [self dismissAlert:nil];
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionLater}];
}

#pragma mark - Internet Connectivity Listener

- (void)listenForInternetConnectivityChanges {
    [self stopListeningForInternetConnectivityChanges];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(showNoInternetAlert)
                   name:SENAPIUnreachableNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(dismissNoInternetAlert)
                   name:SENAPIReachableNotification
                 object:nil];
}

- (void)stopListeningForInternetConnectivityChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:SENAPIUnreachableNotification object:nil];
    [center removeObserver:self name:SENAPIReachableNotification object:nil];
}

- (void)showNoInternetAlert {
    if ([self alertView]) {
        DDLogVerbose(@"another alert is currently shown, skip showing no internet alert");
        return;
    }
    
    NSString* title = NSLocalizedString(@"alerts.no-internet.title", nil);
    NSString* message = NSLocalizedString(@"alerts.no-internet.message", nil);
    NSString* cancelTitle = NSLocalizedString(@"actions.ok", nil);
    
    HEMActionView* alert = [self configureAlertViewWithTitle:title
                                                     message:message
                                           cancelButtonTitle:cancelTitle
                                              fixButtonTitle:nil];
    
    [self setAlertView:alert];
    [[self alertView] setTag:HEMSystemAlertTypeNoInternet];
    
    [[[self alertView] cancelButton] addTarget:self
                                        action:@selector(cancelAlert:)
                              forControlEvents:UIControlEventTouchUpInside];
    [[self alertView] showInView:[[self viewController] view] animated:YES completion:nil];
    
    [SENAnalytics track:HEMAnalyticsEventSystemAlert
             properties:@{kHEMAnalyticsEventPropType : @"no internet"}];
}

- (void)dismissNoInternetAlert {
    if ([[self alertView] tag] == HEMSystemAlertTypeNoInternet) {
        [self dismissAlert:nil];
    }
}

#pragma mark - Time Zone

- (void)checkTimeZone {
    __weak typeof(self) weakSelf = self;
    [SENAPITimeZone getConfiguredTimeZone:^(NSTimeZone* data, NSError *error) {
        if (data == nil && error == nil) {
            [weakSelf showTimeZoneWarning];
        }
    }];
}

- (void)showTimeZoneWarning {
    if ([self alertView] != nil) {
        DDLogVerbose(@"another alert is currently shown, skip showing time zone alert");
        return;
    }
    
    NSString* title = NSLocalizedString(@"alerts.timezone.title", nil);
    NSString* message = NSLocalizedString(@"alerts.timezone.message", nil);
    NSString* cancelTitle = NSLocalizedString(@"actions.later", nil);
    NSString* fixTitle = NSLocalizedString(@"actions.fix-now", nil);
    
    HEMActionView* alert = [self configureAlertViewWithTitle:title
                                                     message:message
                                           cancelButtonTitle:cancelTitle
                                              fixButtonTitle:fixTitle];
    [self setAlertView:alert];
    [[self alertView] setTag:HEMSystemAlertTypeNoTimeZone];
    [[[self alertView] cancelButton] addTarget:self
                                        action:@selector(cancelAlert:)
                              forControlEvents:UIControlEventTouchUpInside];
    [[[self alertView] okButton] addTarget:self
                                    action:@selector(fixTimeZoneNow:)
                          forControlEvents:UIControlEventTouchUpInside];
    [[self alertView] showInView:[[self viewController] view] animated:YES completion:nil];
    
    [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageSystemAlertShown];
    
    [SENAnalytics track:HEMAnalyticsEventSystemAlert
             properties:@{kHEMAnalyticsEventPropType : @"time zone"}];
}

- (void)fixTimeZoneNow:(id)sender {
    [self dismissAlert:^{
        UIViewController* tzVC = [HEMMainStoryboard instantiateTimeZoneNavViewController];
        [self setModalTransitionDelegate:[[HEMBounceModalTransition alloc] init]];
        [tzVC setTransitioningDelegate:[self modalTransitionDelegate]];
        [tzVC setModalPresentationStyle:UIModalPresentationCustom];
        [[self viewController] presentViewController:tzVC animated:YES completion:nil];
    }];
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionNow}];
}

#pragma mark - Devices

- (NSString*)analyticsPropertyTypeValueForDeviceState:(SENServiceDeviceState)state {
    switch (state) {
        case SENServiceDeviceStatePillLowBattery:
            return @"pill has low battery";
        case SENServiceDeviceStatePillNotPaired:
            return @"pill is not paired";
        case SENServiceDeviceStatePillNotSeen:
            return @"pill has not been seen for awhile";
        case SENServiceDeviceStateSenseNotSeen:
            return @"sense has not been seen for awhile";
        case SENServiceDeviceStateSenseNotPaired:
            return @"sense is not paired";
        default:
            return @"unknown";
    }
}

- (void)checkSystemIfEnabled {
    if ([self enableSystemMonitoring]) {
        [self checkConnectionState];
        [self checkDevicesState];
        [self listenForInternetConnectivityChanges];
    }
}

- (void)checkDevicesState {
    __weak typeof(self) weakSelf = self;
    [[SENServiceDevice sharedService] checkDevicesState:^(SENServiceDeviceState state) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (state != SENServiceDeviceStateUnknown && state != SENServiceDeviceStateNormal) {
            [strongSelf showDeviceWarning];
        } else {
            [strongSelf checkTimeZone];
        }
    }];
}

- (void)checkConnectionState {
    // need to wait a short delay since at first, the state is unknown
    __weak typeof(self) weakSelf = self;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5f*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([SENAPIClient isAPIReachable]) {
            [strongSelf dismissNoInternetAlert];
        } else {
            [strongSelf showNoInternetAlert];
        }
    });
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
    HEMSystemAlertType alertType = HEMSystemAlertTypeUnknown;
    
    SENServiceDevice* service = [SENServiceDevice sharedService];
    [self deviceWarningTitle:&title
                     message:&message
           cancelButtonTitle:&cancelTitle
              fixButtonTitle:&fixTitle
                   alertType:&alertType];
    
    if ( alertType != HEMSystemAlertTypeUnknown ) {
        [self showDeviceWarningWithTitle:title
                                 message:message
                       cancelButtonTitle:cancelTitle
                          fixButtonTitle:fixTitle
                                 forType:alertType];
        
        NSString* analyticsType = [self analyticsPropertyTypeValueForDeviceState:[service deviceState]];
        
        [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageSystemAlertShown];
        
        [SENAnalytics track:HEMAnalyticsEventSystemAlert
                 properties:@{kHEMAnalyticsEventPropType : analyticsType}];
    }
    
}

- (void)deviceWarningTitle:(NSString**)warningTitle
                   message:(NSString**)warningMessage
         cancelButtonTitle:(NSString**)cancelTitle
            fixButtonTitle:(NSString**)fixTitle
                 alertType:(HEMSystemAlertType*)type {
    
    SENServiceDevice* service = [SENServiceDevice sharedService];
    switch ([service deviceState]) {
        case SENServiceDeviceStateSenseNotPaired:
            *warningTitle = NSLocalizedString(@"alerts.device.no-sense.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.no-sense.message", nil);
            *type = HEMSystemAlertTypeNoSensePaired;
            break;
        case SENServiceDeviceStateSenseNotSeen:
            *warningTitle = NSLocalizedString(@"alerts.device.sense-last-seen.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.sense-last-seen.message", nil);
            *type = HEMSystemAlertTypeSenseNotSeen;
            break;
        case SENServiceDeviceStatePillNotPaired:
            *warningTitle = NSLocalizedString(@"alerts.device.no-pill.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.no-pill.message", nil);
            *type = HEMSystemAlertTypeNoPillPaired;
            break;
        case SENServiceDeviceStatePillNotSeen:
            *warningTitle = NSLocalizedString(@"alerts.device.pill-last-seen.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.pill-last-seen.message", nil);
            *type = HEMSystemAlertTypePillNotSeen;
            break;
        case SENServiceDeviceStatePillLowBattery:
            *warningMessage = NSLocalizedString(@"alerts.device.pill-low-battery.message", nil);
            *cancelTitle = NSLocalizedString(@"actions.later", nil);
            *fixTitle = NSLocalizedString(@"actions.replace", nil);
            *type = HEMSystemAlertTypePillLowBattery;
            break;
        default:
            *type = HEMSystemAlertTypeUnknown;
            break;
    }
    
    if (*type != HEMSystemAlertTypeUnknown) {
        if (*cancelTitle == nil) {
            *cancelTitle = NSLocalizedString(@"actions.later", nil);
        }
        
        if (*fixTitle == nil) {
            *fixTitle = NSLocalizedString(@"actions.fix-now", nil);
        }
    }

}

- (void)showDeviceWarningWithTitle:(NSString*)title
                           message:(NSString*)message
                 cancelButtonTitle:(NSString*)cancelTitle
                    fixButtonTitle:(NSString*)fixTitle
                           forType:(HEMSystemAlertType)type {
    
    HEMActionView* alert = [self configureAlertViewWithTitle:title
                                                     message:message
                                           cancelButtonTitle:cancelTitle
                                              fixButtonTitle:fixTitle];
    [self setAlertView:alert];
    [[self alertView] setTag:type];
    [[[self alertView] cancelButton] addTarget:self
                                        action:@selector(fixDeviceProblemLater:)
                              forControlEvents:UIControlEventTouchUpInside];
    [[[self alertView] okButton] addTarget:self
                                    action:@selector(fixDeviceProblemNow:)
                          forControlEvents:UIControlEventTouchUpInside];
    [[self alertView] showInView:[[self viewController] view] animated:YES completion:nil];
}

- (void)fixDeviceProblemLater:(id)sender {
    [self dismissAlert:nil];
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionLater}];
}

- (void)fixDeviceProblemNow:(id)sender {
    HEMSystemAlertType alertType = [[self alertView] tag];
    [self dismissAlert:^{
        [self launchHandlerForDeviceAlertType:alertType];
    }];
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionNow}];
}

- (void)launchHandlerForDeviceAlertType:(HEMSystemAlertType)type {
    // supported warnings are handled below
    switch (type) {
        case HEMSystemAlertTypeNoSensePaired:
            [self showSensePairController];
            break;
        case HEMSystemAlertTypeSenseNotSeen:
            [self showSenseHelp];
            break;
        case HEMSystemAlertTypeNoPillPaired:
            [self showPillPairController];
            break;
        case HEMSystemAlertTypePillNotSeen:
            [self showPillHelp];
            break;
        case HEMSystemAlertTypePillLowBattery:
            [self showHowToReplacePillBattery];
            break;
        default:
            break;
    }
}

- (void)dismissAlert:(void(^)(void))completion {
    [[self alertView] dismiss:YES completion:^{
        [self setAlertView:nil];
        [self stopListeningForPairingChanges];
        if (completion) completion ();
    }];
}

- (void)listenForPairingChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didUpdatePairing:)
                   name:HEMOnboardingNotificationDidChangeSensePairing
                 object:nil];
    [center addObserver:self
               selector:@selector(didUpdatePairing:)
                   name:HEMOnboardingNotificationDidChangePillPairing
                 object:nil];
}

- (void)stopListeningForPairingChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:HEMOnboardingNotificationDidChangeSensePairing object:nil];
    [center removeObserver:self name:HEMOnboardingNotificationDidChangePillPairing object:nil];
}

- (void)didUpdatePairing:(NSNotification*)notification {
    switch ([[self alertView] tag]) {
        case HEMSystemAlertTypeNoSensePaired:
        case HEMSystemAlertTypeNoPillPaired:
            [self dismissAlert:nil];
            break;
        default:
            break;
    }
}

#pragma mark - Sense Problems

- (void)showSensePairController {
    [self listenForPairingChanges];
    
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

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Pill Problems

- (void)showPillPairController {
    [self listenForPairingChanges];
    
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
    [self setEnableSystemMonitoring:NO];
}

#pragma mark - Clean Up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
