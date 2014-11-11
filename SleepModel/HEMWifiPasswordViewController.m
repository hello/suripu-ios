//
//  HEMWifiViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPITimeZone.h>
#import <SenseKit/SENSenseMessage.pb.h>

#import "HEMWifiPasswordViewController.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMUserDataCache.h"
#import "HEMWifiUtils.h"
#import "HEMRoundedTextField.h"
#import "HEMDeviceCenter.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMActivityCoverView.h"

typedef NS_ENUM(NSUInteger, HEMWiFiSetupStep) {
    HEMWiFiSetupStepNone = 0,
    HEMWiFiSetupStepConfigureWiFi = 1,
    HEMWiFiSetupStepLinkAccount = 2,
    HEMWiFiSetupStepSetTimezone = 3,
    HEMWiFiSetupStepDone = 4
};

@interface HEMWifiPasswordViewController() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *ssidField;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *passwordField;

@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (copy,   nonatomic) NSString* ssidConfigured;
@property (assign, nonatomic) HEMWiFiSetupStep stepFinished;

@end

@implementation HEMWifiPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self doneButton] setTitleColor:[HelloStyleKit senseBlueColor]
                            forState:UIControlStateNormal];
    
    if ([self endpoint] != nil) {
        [[self ssidField] setText:[[self endpoint] ssid]];
    }
    
    [SENAnalytics track:kHEMAnalyticsEventOnBSetupWiFi];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[[self ssidField] text] length] == 0) {
        [[self ssidField] becomeFirstResponder];
    } else {
        [[self passwordField] becomeFirstResponder];
    }
}

- (void)enableControls:(BOOL)enable {
    if (!enable) {
        if ([[self ssidField] isFirstResponder]) {
            [[self ssidField] resignFirstResponder];
        } else if ([[self passwordField] isFirstResponder]) {
            [[self passwordField] resignFirstResponder];
        }
    }
    
    [[self ssidField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    [[self doneButton] setEnabled:enable];
    [[self navigationItem] setHidesBackButton:!enable animated:YES];
    
    if (enable) {
        [[self passwordField] becomeFirstResponder];
    }
}

- (BOOL)shouldLinkAccount {
    // When we reuse this controller in settings, pairedSenseAvailable will
    // be true and in that case, we should not need to linkAccount again.
    return ![[HEMDeviceCenter sharedCenter] pairedSenseAvailable];
}

- (void)setTimeZone {
    __weak typeof(self) weakSelf = self;
    [SENAPITimeZone setCurrentTimeZone:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && error != nil) {
            DDLogWarn(@"failed to set timezone on the server");
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
        }
    }];
}

- (SENSenseManager*)manager {
    SENSenseManager* manager = [[HEMDeviceCenter sharedCenter] senseManager];
    return manager ? manager : [[HEMUserDataCache sharedUserDataCache] senseManager];
}

- (BOOL)isValid:(NSString*)ssid pass:(NSString*)pass {
    return [ssid length] > 0
            && ([self endpoint] == nil
                || ([[self endpoint] security] != SENWifiEndpointSecurityTypeOpen
                    && [pass length] > 0));
}

- (SENWifiEndpointSecurityType)selectedSecurityType {
    SENWifiEndpointSecurityType type = SENWifiEndpointSecurityTypeWpa2; // default, per discussion
    if ([self endpoint] != nil) {
        type = [[self endpoint] security];
    }
    return type;
}

#pragma mark - Activity

- (void)showActivityWithText:(NSString*)text completion:(void(^)(void))completion {
    [self enableControls:NO];
    
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    
    UIView* viewToAttach = [[self navigationController] view];
    [[self activityView] showInView:viewToAttach
                           withText:text
                           activity:YES
                         completion:completion];
}

- (void)stopActivityWithMessage:(NSString*)message
                renableControls:(BOOL)enable
                     completion:(void(^)(void))completion {
    [[self activityView] dismissWithResultText:message remove:YES completion:^{
        [self enableControls:enable];
        if (completion) completion ();
    }];
}

- (void)updateActivity:(NSString*)message {
    if ([[self activityView] isShowing]) {
        [[self activityView] updateText:message completion:nil];
    } else {
        [self showActivityWithText:message completion:nil];
    }
}

#pragma mark - Steps To Set Up

- (void)setupWiFi:(NSString*)ssid
         password:(NSString*)password
     securityType:(SENWifiEndpointSecurityType)type {
    
    __weak typeof(self) weakSelf = self;
    SENSenseManager* manager = [self manager];
    [manager setWiFi:ssid password:password securityType:type success:^(id response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setSsidConfigured:ssid];
        [strongSelf setStepFinished:HEMWiFiSetupStepConfigureWiFi];
        [strongSelf executeNextStep];
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf stopActivityWithMessage:nil renableControls:YES completion:^{
            [strongSelf showSetWiFiError:error];
        }];
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    }];

}

- (void)linkAccount {
    if (![self shouldLinkAccount]) {
        [self setStepFinished:HEMWiFiSetupStepLinkAccount];
        [self executeNextStep];
        return;
    }
    
    NSString* accessToken = [SENAuthorizationService accessToken];
    SENSenseManager* manager = [self manager];
    
    if (accessToken == nil) {
        // FIXME (jimmy): i've hit this case once, but have not reproduced it
        // we need to find this problem and recover from it!
        DDLogWarn(@"account was not set up correctly! access token missing!");
        NSString* msg = NSLocalizedString(@"wifi.error.missing-access-token", nil);
        NSString* title = NSLocalizedString(@"wifi.error.title", nil);
        [self showMessageDialog:msg title:title];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [manager linkAccount:accessToken success:^(id response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setStepFinished:HEMWiFiSetupStepLinkAccount];
            [strongSelf executeNextStep];
        }
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf stopActivityWithMessage:nil renableControls:YES completion:^{
                NSString* msg = NSLocalizedString(@"wifi.error.account-link-message", nil);
                NSString* title = NSLocalizedString(@"wifi.error.title", nil);
                [strongSelf showMessageDialog:msg title:title];
            }];
        }
        
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    }];
}

- (void)setupTimezone {
    __weak typeof(self) weakSelf = self;
    [SENAPITimeZone setCurrentTimeZone:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error == nil) {
                [strongSelf setStepFinished:HEMWiFiSetupStepSetTimezone];
                [strongSelf executeNextStep];
            } else {
                DDLogWarn(@"failed to set timezone on the server");
                [strongSelf stopActivityWithMessage:nil renableControls:YES completion:^{
                    NSString* msg = NSLocalizedString(@"wifi.error.time-zone-failed", nil);
                    NSString* title = NSLocalizedString(@"wifi.error.title", nil);
                    [strongSelf showMessageDialog:msg title:title];
                }];
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            }

        }
    }];
}

- (void)finish {
    NSString* msg = NSLocalizedString(@"wifi.setup.complete", nil);
    __weak typeof(self) weakSelf = self;
    [self stopActivityWithMessage:msg renableControls:NO completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([strongSelf delegate] != nil) {
                [[strongSelf delegate] didConfigureWiFiTo:[strongSelf ssidConfigured] from:strongSelf];
            } else {
                [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointSenseDone];
                [strongSelf performSegueWithIdentifier:[HEMOnboardingStoryboard senseToPillSegueIdentifier]
                                                sender:nil];
            }
        }
    }];
}

- (void)executeNextStep {

    switch ([self stepFinished]) {
        case HEMWiFiSetupStepNone: {
            // from a google search, spaces are allowed in both ssid and passwords so we
            // will have to take the values as is.
            NSString* ssid = [[self ssidField] text];
            NSString* pass = [[self passwordField] text];
            if ([self isValid:ssid pass:pass]) {
                NSString* message = NSLocalizedString(@"wifi.activity.setting-wifi", nil);
                [self showActivityWithText:message completion:^{
                    [self setupWiFi:ssid password:pass securityType:[self selectedSecurityType]];
                }];
            }
            break;
        }
        case HEMWiFiSetupStepConfigureWiFi: {
            NSString* message = NSLocalizedString(@"pairing.activity.linking-account", nil);
            [self updateActivity:message];
            [self linkAccount];
            break;
        }
        case HEMWiFiSetupStepLinkAccount: {
            NSString* message = NSLocalizedString(@"wifi.activity.setting-timezone", nil);
            [self updateActivity:message];
            [self setupTimezone];
            break;
        }
        case HEMWiFiSetupStepSetTimezone:
        default: {
            [self finish];
            break;
        }
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == [self ssidField]) {
        [[self passwordField] becomeFirstResponder];
    } else {
        [self connectWifi:self];
    }
    return YES;
}

#pragma mark - Actions

- (IBAction)connectWifi:(id)sender {
    [self executeNextStep];
}

- (IBAction)help:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
}

#pragma mark - Errors / Alerts

- (void)showSetWiFiError:(NSError*)error {
    NSString* title = NSLocalizedString(@"wifi.error.title", nil);
    NSString* message = nil;
    
    switch ([error code]) {
        case SENSenseManagerErrorCodeWifiNotInRange:
            message = NSLocalizedString(@"wifi.error.set-sense-not-in-range", nil);
            break;
        case SENSenseManagerErrorCodeTimeout:
            message = NSLocalizedString(@"wifi.error.set-sense-timeout", nil);
            break;
        case SENSenseManagerErrorCodeWLANConnection:
        case SENSenseManagerErrorCodeFailToObtainIP:
            message = NSLocalizedString(@"wifi.error.set-sense-failed-connection", nil);
            break;
        default:
            message = NSLocalizedString(@"wifi.error.set-sense-general", nil);
            break;
    }
    
    [self showMessageDialog:message title:title];
}

- (void)showLinkAccountError:(NSError*)error {
    NSString* title = NSLocalizedString(@"wifi.error.title", nil);
    NSString* message = nil;
    
    switch ([error code]) {
        case SENSenseManagerErrorCodeSenseNetworkError:
            message = NSLocalizedString(@"wifi.error.account-link-network-failed", nil);
            break;
        case SENSenseManagerErrorCodeTimeout:
            message = NSLocalizedString(@"wifi.error.account-link-timeout", nil);
            break;
        default:
            message = NSLocalizedString(@"wifi.error.account-link-message", nil);
            break;
    }
    
    [self showMessageDialog:message title:title];
}

@end
