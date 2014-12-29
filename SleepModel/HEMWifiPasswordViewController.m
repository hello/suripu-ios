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

#import "UIFont+HEMStyle.h"

#import "HEMWifiPasswordViewController.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingCache.h"
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

static CGFloat const kHEMWifiSecurityPickerDefaultHeight = 216.0f;
static CGFloat const kHEMWifiSecurityLabelDefaultWidth = 50.0f;

@interface HEMWifiPasswordViewController() <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *ssidField;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *passwordField;
@property (weak, nonatomic) IBOutlet HEMRoundedTextField *securityField;

@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (strong, nonatomic) UIPickerView* securityPickerView;
@property (copy,   nonatomic) NSString* ssidConfigured;
@property (assign, nonatomic) SENWifiEndpointSecurityType securityType;
@property (assign, nonatomic) HEMWiFiSetupStep stepFinished;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ssidTopConstraint;

@end

@implementation HEMWifiPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    
    [[self doneButton] setTitleColor:[HelloStyleKit senseBlueColor]
                            forState:UIControlStateNormal];
    [[[self doneButton] titleLabel] setFont:[UIFont navButtonTitleFont]];
    
    if ([self endpoint] != nil) {
        [[self ssidField] setText:[[self endpoint] ssid]];
        [self setSecurityType:[[self endpoint] security]];
        [[self securityField] setHidden:YES];
    } else { // default to WPA2
        [self setSecurityType:SENWifiEndpointSecurityTypeWpa2];
    }
    
    [self setupSecurityPickerView];
    [self updateSecurityTypeLabelForRow:[self rowForSecurityType:[self securityType]]];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBWiFiPass];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect pickerBounds = [[self securityPickerView] bounds];
    pickerBounds.size.width = CGRectGetWidth([[self view] bounds]);
    [[self securityPickerView] setBounds:pickerBounds];
}

- (void)adjustConstraintsForIPhone4 {
    [[self subtitleLabel] setHidden:YES];
    
    CGFloat reducePadding = 8.0f;
    CGFloat currentSpacing = -([[self ssidTopConstraint] constant]);
    CGFloat subtitleHeight = CGRectGetHeight([[self subtitleLabel] bounds]);
    CGFloat diff = (subtitleHeight + currentSpacing + reducePadding);
    [self updateConstraint:[self ssidTopConstraint] withDiff:diff];
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
        } else if ([[self securityField] isFirstResponder]) {
            [[self securityField] resignFirstResponder];
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
    return manager ? manager : [[HEMOnboardingCache sharedCache] senseManager];
}

- (BOOL)isValid:(NSString*)ssid pass:(NSString*)pass {
    return [ssid length] > 0
            && ([self securityType] == SENWifiEndpointSecurityTypeOpen
                || ([self securityType] != SENWifiEndpointSecurityTypeOpen
                    && [pass length] > 0));
}

#pragma mark - Security Picker

- (void)setupSecurityPickerView {
    CGRect pickerFrame = CGRectZero;
    pickerFrame.size.width = CGRectGetWidth([[self view] bounds]);
    pickerFrame.size.height = kHEMWifiSecurityPickerDefaultHeight;
    
    UIPickerView* securityPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    [securityPicker setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [securityPicker setTranslatesAutoresizingMaskIntoConstraints:YES];
    [securityPicker setBackgroundColor:[UIColor whiteColor]];
    [securityPicker setDelegate:self];
    [securityPicker setDataSource:self];
    
    [self setSecurityPickerView:securityPicker];
    [[self securityField] setInputView:securityPicker];
    
    [self matchPickerToKeyboardHeight];
}

- (void)matchPickerToKeyboardHeight {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    // block to capture the observer, weak to ensure there won't be a leak.  w/o
    // leak, we will need to set observer to nil after removing it
    __weak typeof(self) weakSelf = self;
    __block __weak id observer =
    [center addObserverForName:UIKeyboardWillShowNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                        
                        if (strongSelf) {
                            NSDictionary* info  =[note userInfo];
                            CGRect keyboardFrame = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
                            CGRect pickerBounds = [[strongSelf securityPickerView] bounds];
                            pickerBounds.size.height = CGRectGetHeight(keyboardFrame);
                            [[strongSelf securityPickerView] setBounds:pickerBounds];
                        }
                    }];
}

- (SENWifiEndpointSecurityType)securityTypeForPickerRow:(NSInteger)row {
    SENWifiEndpointSecurityType securityType;
    switch (row) {
        case 1:
            securityType = SENWifiEndpointSecurityTypeWpa;
            break;
        case 2:
            securityType = SENWifiEndpointSecurityTypeWep;
            break;
        case 3:
            securityType = SENWifiEndpointSecurityTypeOpen;
            break;
        case 0:
        default:
            securityType = SENWifiEndpointSecurityTypeWpa2;
            break;
    }
    return securityType;
}

- (NSString*)securityTypeTextForPickerRow:(NSInteger)row {
    NSString* securityType = nil;
    switch (row) {
        case 0:
            securityType = NSLocalizedString(@"wifi.security.wpa2", nil);
            break;
        case 1:
            securityType = NSLocalizedString(@"wifi.security.wpa", nil);
            break;
        case 2:
            securityType = NSLocalizedString(@"wifi.security.wep", nil);
            break;
        case 3:
            securityType = NSLocalizedString(@"wifi.security.open", nil);
            break;
        default:
            break;
    }
    return securityType;
}

- (NSInteger)rowForSecurityType:(SENWifiEndpointSecurityType)securityType {
    NSInteger pickerRow;
    switch (securityType) {
        case SENWifiEndpointSecurityTypeWpa:
            pickerRow = 1;
            break;
        case SENWifiEndpointSecurityTypeWep:
            pickerRow = 2;
            break;
        case SENWifiEndpointSecurityTypeOpen:
            pickerRow = 3;
            break;
        case SENWifiEndpointSecurityTypeWpa2:
        default:
            pickerRow = 0;
            break;
    }
    return pickerRow;
}

- (void)updateSecurityTypeLabelForRow:(NSInteger)row {
    UILabel* selectedTypeLabel = (UILabel*)[[self securityField] rightView];
    if (selectedTypeLabel == nil) {
        CGRect labelFrame = CGRectZero;
        labelFrame.size.height = CGRectGetHeight([[self securityField] bounds]);
        labelFrame.size.width = kHEMWifiSecurityLabelDefaultWidth;
        selectedTypeLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [selectedTypeLabel setFont:[UIFont onboardingFieldRightViewFont]];
        [selectedTypeLabel setTextColor:[UIColor blackColor]];
        [[self securityField] setRightView:selectedTypeLabel];
        [[self securityField] setRightViewMode:UITextFieldViewModeAlways];
    }
    
    [selectedTypeLabel setText:[self securityTypeTextForPickerRow:row]];
    [selectedTypeLabel sizeToFit];
    [self setSecurityType:[self securityTypeForPickerRow:row]];
}

#pragma mark UIPickerViewDelegate / DataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString* securityType = [self securityTypeTextForPickerRow:row];
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont singleComponentPickerViewFont]};
    NSAttributedString* attrSecurity = [[NSAttributedString alloc] initWithString:securityType attributes:attributes];
    return attrSecurity;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self updateSecurityTypeLabelForRow:row];
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
                        success:(BOOL)success
                     completion:(void(^)(void))completion {
    [[self activityView] dismissWithResultText:message showSuccessMark:success remove:YES completion:^{
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
        [strongSelf stopActivityWithMessage:nil renableControls:YES success:NO completion:^{
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
    
    NSString* message = NSLocalizedString(@"pairing.activity.linking-account", nil);
    [self updateActivity:message];
    
    NSString* accessToken = [SENAuthorizationService accessToken];
    SENSenseManager* manager = [self manager];
    
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
            [strongSelf stopActivityWithMessage:nil renableControls:YES success:NO completion:^{
                NSString* msg = NSLocalizedString(@"wifi.error.account-link-message", nil);
                NSString* title = NSLocalizedString(@"wifi.error.link-account-title", nil);
                [strongSelf showMessageDialog:msg title:title];
            }];
        }
        
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    }];
}

- (void)setupTimezone {
    NSString* message = NSLocalizedString(@"wifi.activity.setting-timezone", nil);
    [self updateActivity:message];
    
    __weak typeof(self) weakSelf = self;
    [SENAPITimeZone setCurrentTimeZone:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error == nil) {
                [strongSelf setStepFinished:HEMWiFiSetupStepSetTimezone];
                [strongSelf executeNextStep];
            } else {
                DDLogWarn(@"failed to set timezone on the server");
                [strongSelf stopActivityWithMessage:nil renableControls:YES success:NO completion:^{
                    NSString* msg = NSLocalizedString(@"wifi.error.time-zone-failed", nil);
                    NSString* title = NSLocalizedString(@"wifi.error.timezone-title", nil);
                    [strongSelf showMessageDialog:msg title:title];
                }];
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            }

        }
    }];
}

- (void)finish {
    // need to start querying for sensor data so that 1, user will see
    // it as soon as onboarding is done and 2, later step will check
    // sensor data
    [[HEMOnboardingCache sharedCache] startPollingSensorData];
    
    [[self manager] setLED:SENSenseLEDStateSuccess success:nil failure:nil];
    
    NSString* msg = NSLocalizedString(@"wifi.setup.complete", nil);
    __weak typeof(self) weakSelf = self;
    [self stopActivityWithMessage:msg renableControls:NO success:YES completion:^{
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
                    [self setupWiFi:ssid password:pass securityType:[self securityType]];
                }];
            }
            break;
        }
        case HEMWiFiSetupStepConfigureWiFi: {
            [self linkAccount];
            break;
        }
        case HEMWiFiSetupStepLinkAccount: {
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
    } else if (textField == [self passwordField]) {
        if (![[self securityField] isHidden]) {
            [[self securityField] becomeFirstResponder];
        } else {
            [self connectWifi:self];
        }
    } else {
        [self connectWifi:self];
    }
    return YES;
}

#pragma mark - Actions

- (IBAction)connectWifi:(id)sender {
    [self executeNextStep];
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
