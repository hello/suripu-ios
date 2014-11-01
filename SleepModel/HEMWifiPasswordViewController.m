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

@interface HEMWifiPasswordViewController() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *ssidField;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *hiddenField;

@property (assign, nonatomic) BOOL wifiConfigured;

@end

@implementation HEMWifiPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
        // keep the keyboard up at all times
        [[self hiddenField] becomeFirstResponder];
    }
    
    [[self ssidField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    [[self doneButton] setEnabled:enable];
    
    if (enable) {
        [[self passwordField] becomeFirstResponder];
    }
}

- (void)showActivity {
    [self enableControls:NO];
    [[self activityIndicator] startAnimating];
}

- (void)stopActivity {
    [[self activityIndicator] stopAnimating];
    [self enableControls:YES];
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
    if (![[self doneButton] isEnabled]) return;
    
    // from a google search, spaces are allowed in both ssid and passwords so we
    // will have to take the values as is.
    NSString* ssid = [[self ssidField] text];
    NSString* pass = [[self passwordField] text];
    if ([ssid length] > 0
        && ([self endpoint] == nil
            || ([[self endpoint] security] != SENWifiEndpointSecurityTypeOpen
                && [pass length] > 0))) {
                
        [self showActivity];
        
        if (![self wifiConfigured]) {
            
            SENWifiEndpointSecurityType type = SENWifiEndpointSecurityTypeWpa2; // default, per discussion
            if ([self endpoint] != nil) {
                type = [[self endpoint] security];
            }
            
            __weak typeof(self) weakSelf = self;
            [self setWiFi:ssid password:pass securityType:type completion:^(NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    if (error == nil) {
                        [strongSelf setWifiConfigured:YES];
                        
                        if ([strongSelf shouldLinkAccount]) {
                            [strongSelf linkAccount];
                        } else {
                            [strongSelf next];
                        }
                        
                    } else {
                        [strongSelf stopActivity];
                        [strongSelf showSetWiFiError:error];
                    }
                }
                
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            }];
        } else if ([self shouldLinkAccount]){
            [self linkAccount];
        } else {
            [self next];
        }
    }
}

- (IBAction)help:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
#pragma message ("remove when we all have devices!")
    
    [self next];
}

- (void)setWiFi:(NSString*)ssid
       password:(NSString*)password
   securityType:(SENWifiEndpointSecurityType)securityType
     completion:(void(^)(NSError* error))completion {

    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    [manager setWiFi:ssid password:password securityType:securityType success:^(id response) {
        if (completion) completion (nil);
    } failure:^(NSError *error) {
        if (completion) completion (error);
    }];
    
}

- (void)linkAccount {
    NSString* accessToken = [SENAuthorizationService accessToken];
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    
    __weak typeof(self) weakSelf = self;
    [manager linkAccount:accessToken success:^(id response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf stopActivity];
            [strongSelf next];
        }
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf stopActivity];
            
            NSString* msg = NSLocalizedString(@"wifi.error.account-link-message", nil);
            NSString* title = NSLocalizedString(@"wifi.error.title", nil);
            [strongSelf showMessageDialog:msg title:title];
        }
        
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    }];
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

#pragma mark - Navigation

- (void)next {
    [self setTimeZone]; // fire and forget (besides logging that it failed)
    [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointSenseDone];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard pillSegueIdentifier]
                              sender:nil];
}

@end
