//
//  HEMWifiViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMWifiViewController.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMUserDataCache.h"
#import "HEMWifiUtils.h"
#import "HEMRoundedTextField.h"

@interface HEMWifiViewController() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *ssidField;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *passwordField;

@property (assign, nonatomic) BOOL wifiConfigured;

@end

@implementation HEMWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    [[self ssidField] setText:[HEMWifiUtils connectedWifiSSID]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[[self ssidField] text] length] == 0) {
        [[self ssidField] becomeFirstResponder];
    } else {
        [[self passwordField] becomeFirstResponder];
    }
}

- (void)showActivity {
    [[self doneButton] setEnabled:NO];
    [[self activityIndicator] startAnimating];
}

- (void)stopActivity {
    [[self activityIndicator] stopAnimating];
    [[self doneButton] setEnabled:YES];
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
    if ([ssid length] > 0 && [pass length] > 0) {
        [self showActivity];
        
        if (![self wifiConfigured]) {
            __weak typeof(self) weakSelf = self;
            [self setWiFi:ssid password:pass completion:^(NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    if (error == nil) {
                        [strongSelf setWifiConfigured:YES];
                        [strongSelf linkAccount];
                    } else {
                        [strongSelf stopActivity];
                        
                        NSString* msg = NSLocalizedString(@"wifi.error.sense-wifi-message", nil);
                        NSString* title = NSLocalizedString(@"wifi.error.title", nil);
                        [strongSelf showMessageDialog:msg title:title];
                    }
                }
            }];
        } else {
            [self linkAccount];
        }
    }
}

- (IBAction)help:(id)sender {
    DLog(@"WARNING: this has not been implemented yet!")
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
}

- (void)setWiFi:(NSString*)ssid
       password:(NSString*)password
     completion:(void(^)(NSError* error))completion {

    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    [manager setWiFi:ssid password:password success:^(id response) {
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
    }];
}

#pragma mark - Navigation

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard pillSegueIdentifier]
                              sender:nil];
}

@end
