//
//  HEMWifiViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENAPITimeZone.h>
#import <SenseKit/SENSenseMessage.pb.h>
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENSenseWiFiStatus.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMWifiPasswordViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingService.h"
#import "HEMWifiUtils.h"
#import "HEMScreenUtils.h"
#import "HEMSimpleLineTextField.h"

typedef NS_ENUM(NSUInteger, HEMWiFiSetupStep) {
    HEMWiFiSetupStepNone = 0,
    HEMWiFiSetupStepConfigureWiFi = 1,
    HEMWiFiSetupStepLinkAccount = 2,
    HEMWiFiSetupStepSetTimezone = 3,
    HEMWiFiSetupStepForceDataUpload = 4
};

static CGFloat const kHEMWifiSecurityPickerDefaultHeight = 216.0f;
static CGFloat const kHEMWifiSecurityLabelDefaultWidth = 50.0f;

@interface HEMWifiPasswordViewController() <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet HEMSimpleLineTextField *ssidField;
@property (weak, nonatomic) IBOutlet HEMSimpleLineTextField *passwordField;
@property (weak, nonatomic) IBOutlet HEMSimpleLineTextField *securityField;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ssidTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *securityTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueTopConstraint;

@property (strong, nonatomic) UIPickerView* securityPickerView;
@property (copy,   nonatomic) NSString* ssidConfigured;
@property (copy,   nonatomic) NSString* disconnectObserverId;
@property (assign, nonatomic) SENWifiEndpointSecurityType securityType;
@property (assign, nonatomic) HEMWiFiSetupStep stepFinished;

@end

@implementation HEMWifiPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureForm];
    [self fireAnalyticsEvent];
}

- (void)fireAnalyticsEvent {
    NSString* other = @"true";
    long rssi = 0;
    if ([self endpoint] != nil) {
        other = @"false";
        rssi = [[self endpoint] rssi];
    }

    [self trackAnalyticsEvent:HEMAnalyticsEventWiFiPass
                         properties:@{kHEMAnalyticsEventPropWiFiOther :other,
                                      kHEMAnalyticsEventPropWiFiRSSI : @(rssi)}];
}

- (void)configureForm {
    if ([self endpoint] != nil) {
        [[self ssidField] setText:[[self endpoint] ssid]];
        [self setSecurityType:[[self endpoint] security]];
        [[self securityField] setHidden:YES];
        [[self passwordField] setHidden:[self securityType] == SENWifiEndpointSecurityTypeOpen];
    } else { // default to WPA2
        [self setSecurityType:SENWifiEndpointSecurityTypeWpa2];
    }

    [self setupSecurityPickerView];
    [self updateSecurityTypeLabelForRow:[self rowForSecurityType:[self securityType]]];
}

- (BOOL)haveDelegates {
    return [self delegate] != nil || [self sensePairDelegate] != nil;
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat paddingDiff = 10.0f;
    [self updateConstraint:[self ssidTopConstraint] withDiff:50.0f];
    [self updateConstraint:[self passTopConstraint] withDiff:paddingDiff];
    [self updateConstraint:[self securityTopConstraint] withDiff:paddingDiff];
    
    [self adjustContinueButtonConstraint];
    [super adjustConstraintsForIPhone4];
}

- (void)adjustConstraintsForIphone5 {
    [self adjustContinueButtonConstraint];
    [super adjustConstraintsForIphone5];
}

- (void)adjustContinueButtonConstraint {
    if (HEMIsIPhone4Family() || HEMIsIPhone5Family()) {
        CGFloat continueButtonDiff = 10.0f;
        if ([[self securityField] isHidden]) {
            continueButtonDiff += 20.0f;
        }
        [self updateConstraint:[self continueTopConstraint] withDiff:continueButtonDiff];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGRect pickerBounds = [[self securityPickerView] bounds];
    pickerBounds.size.width = CGRectGetWidth([[self view] bounds]);
    [[self securityPickerView] setBounds:pickerBounds];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[[self ssidField] text] length] == 0 || [[self passwordField] isHidden]) {
        [[self ssidField] becomeFirstResponder];
    } else {
        [[self passwordField] becomeFirstResponder];
    }
}

- (void)enableControls:(BOOL)enable {
    if (!enable) {
        [[self view] endEditing:YES];
    }

    [[self ssidField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    [[self continueButton] setEnabled:enable];
    [[self navigationItem] setHidesBackButton:!enable animated:YES];

    if (enable && [self isVisible]) {
        [[self passwordField] becomeFirstResponder];
    }
}

- (BOOL)shouldLinkAccount {
    // When we reuse this controller in settings, pairedSenseAvailable will
    // be true and in that case, we should not need to linkAccount again.
    return ![[SENServiceDevice sharedService] pairedSenseAvailable];
}

- (void)setTimeZone {
    __weak typeof(self) weakSelf = self;
    [SENAPITimeZone setCurrentTimeZone:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && error != nil) {
            DDLogWarn(@"failed to set timezone on the server");
            [SENAnalytics trackError:error];
        }
    }];
}

- (BOOL)isValid:(NSString*)ssid pass:(NSString*)pass {
    BOOL valid = YES;
    if ([ssid length] == 0) {
        valid = NO;
    } else if ([self securityType] != SENWifiEndpointSecurityTypeOpen
               && [pass length] == 0) {
        valid = NO;
    } else if ([self securityType] == SENWifiEndpointSecurityTypeWep) {
        valid = [SENSenseManager isWepKeyValid:pass];
    }
    return valid;
}

- (void)observeUnexpectedDisconnects {
    if ([self disconnectObserverId] == nil) {
        __weak typeof(self) weakSelf = self;
        self.disconnectObserverId =
            [[self manager] observeUnexpectedDisconnect:^(NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                // only show error message if view is visible and the step finished is
                // not linking account, which has nothing to do with Sense so we do
                // not care if it unexpected disconnected there and also because the
                // subsequent steps will attempt to reconnect anyways
                if ([strongSelf isVisible] && [strongSelf stepFinished] != HEMWiFiSetupStepLinkAccount) {
                    NSString* title = NSLocalizedString(@"wifi.error.title", nil);
                    NSString* message = NSLocalizedString(@"wifi.error.unexpected-disconnnect", nil);
                    [strongSelf showErrorMessage:message withTitle:title];
                }
            }];
    }
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

    [self showActivityWithMessage:text completion:^{
        [[self manager] setLED:SENSenseLEDStateActivity completion:^(id response, NSError *error) {
            if (completion) completion();
        }];
    }];
}

- (void)stopActivityWithMessage:(NSString*)message
                renableControls:(BOOL)enable
                        success:(BOOL)success
                     completion:(void(^)(void))completion {

    __weak typeof(self) weakSelf = self;
    void(^stopActivity)(void) = ^{
        [weakSelf stopActivityWithMessage:message success:success completion:^{
            [weakSelf enableControls:enable];
            if (completion) completion ();
        }];
    };
    // if it's not connected, forget about the LED, Sense should turn if off then
    if ([[self manager] isConnected]) {
        SENSenseLEDState led = ![self haveDelegates] ? SENSenseLEDStatePair : SENSenseLEDStateOff;
        [[self manager] setLED:led completion:^(id response, NSError *error) {
            stopActivity();
        }];
    } else {
        stopActivity();
    }

}

#pragma mark - Analytics Helpers

- (NSString*)analyticsValueForSecurityType:(SENWifiEndpointSecurityType)type {
    switch (type) {
        case SENWifiEndpointSecurityTypeOpen:
            return @"open";
        case SENWifiEndpointSecurityTypeWep:
            return @"wep";
        case SENWifiEndpointSecurityTypeWpa:
            return @"wpa";
        case SENWifiEndpointSecurityTypeWpa2:
            return @"wpa2";
        default:
            return @"unknown";
    }
}

#pragma mark - Steps To Set Up

- (void)setupWiFi:(NSString*)ssid
         password:(NSString*)password
     securityType:(SENWifiEndpointSecurityType)type {

    NSDictionary* properties = @{
        kHEMAnalyticsEventPropSecurityType : [self analyticsValueForSecurityType:type],
        kHEMAnalyticsEventPropSSID : ssid ?: @"undefined",
        kHEMAnalyticsEventPropPassLength : @([password length])
    };
    [self trackAnalyticsEvent:HEMAnalyticsEventWiFiSubmit
                         properties:properties];

    __weak typeof(self) weakSelf = self;
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    [service setWiFi:ssid password:password securityType:type update:^(SENSenseWiFiStatus *status) {
        NSDictionary* properties = @{HEMAnalyticsEventPropWiFiStatus : @([status state]),
                                     HEMAnalyticsEventPropHttpCode : [status httpStatusCode] ?: @"",
                                     HEMAnalyticsEventPropSocketCode : @([status socketErrorCode])};
        [weakSelf trackAnalyticsEvent:HEMAnalyticsEventWiFiConnectionUpdate properties:properties];
    } completion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showSetWiFiError:error];
            [SENAnalytics trackError:error];
            return;
        }
        [strongSelf setSsidConfigured:ssid];
        [strongSelf setStepFinished:HEMWiFiSetupStepConfigureWiFi];
        [strongSelf executeNextStep];
    }];
}

- (void)linkAccount {
    if (![self shouldLinkAccount]) {
        [self setStepFinished:HEMWiFiSetupStepLinkAccount];
        [self executeNextStep];
        return;
    }

    [self enableControls:NO];
    NSString* message = NSLocalizedString(@"pairing.activity.linking-account", nil);
    [self updateActivityText:message completion:nil];

    __weak typeof(self) weakSelf = self;
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    [service linkCurrentAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf setStepFinished:HEMWiFiSetupStepLinkAccount];
            [strongSelf executeNextStep];
        } else {
            [weakSelf showLinkAccountError:error];
            [SENAnalytics trackError:error];
        }
    }];
}

- (void)setupTimezone {
    [self enableControls:NO];
    
    __weak typeof(self) weakSelf = self;
    NSString* message = NSLocalizedString(@"wifi.activity.setting-timezone", nil);
    [self updateActivityText:message completion:^(BOOL finished) {
        [SENAPITimeZone setCurrentTimeZone:^(id data, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error == nil) {
                [strongSelf setStepFinished:HEMWiFiSetupStepSetTimezone];
                [strongSelf executeNextStep];
            } else {
                DDLogWarn(@"failed to set timezone on the server");
                NSString* msg = NSLocalizedString(@"wifi.error.time-zone-failed", nil);
                NSString* title = NSLocalizedString(@"wifi.error.timezone-title", nil);
                [strongSelf showErrorMessage:msg withTitle:title];
                [SENAnalytics trackError:error];
            }
        }];
    }];
}

- (void)forceSensorDataUpload {
    __weak typeof(self) weakSelf = self;
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    [service forceSensorDataUploadFromSense:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            DDLogVerbose(@"failed to upload data %@", error);
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventWarning];
        }
        [strongSelf setStepFinished:HEMWiFiSetupStepForceDataUpload];
        [strongSelf executeNextStep];
    }];
}

- (void)finish {
    __weak typeof(self) weakSelf = self;
    void(^proceed)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;

        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        [service notifyOfSensePairingChange];

        if ([strongSelf delegate] != nil) { // Edit-WiFi in settings
            [[HEMOnboardingService sharedService] clear]; // don't clear all, aka disconnect from Sense, or else issues arise
            [[strongSelf delegate] didConfigureWiFiTo:[strongSelf ssidConfigured] from:strongSelf];
        } else if ([strongSelf sensePairDelegate] != nil) { // pairing from inside app (not onboarding)
            __block SENSenseManager* manager = [strongSelf manager];
            [[HEMOnboardingService sharedService] clearAll];
            [[strongSelf sensePairDelegate] didSetupWiFiForPairedSense:manager from:strongSelf];
        } else {
            [[HEMOnboardingService sharedService] saveOnboardingCheckpoint:HEMOnboardingCheckpointSenseDone];
            [strongSelf performSegueWithIdentifier:[HEMOnboardingStoryboard wifiToPillSegueIdentifier]
                                            sender:nil];
        }
    };

    NSString* msg = NSLocalizedString(@"wifi.setup.complete", nil);
    [self stopActivityWithMessage:msg renableControls:NO success:YES completion:proceed];
}

- (void)executeNextStep {

    switch ([self stepFinished]) {
        case HEMWiFiSetupStepNone: {
            // from a google search, spaces are allowed in both ssid and passwords so we
            // will have to take the values as is.
            NSString* ssid = [[self ssidField] text];
            NSString* pass = [[self passwordField] text];
            if ([self isValid:ssid pass:pass]) {
                [self observeUnexpectedDisconnects];
                NSString* message = NSLocalizedString(@"wifi.activity.setting-wifi", nil);
                [self showActivityWithText:message completion:^{
                    [self setupWiFi:ssid password:pass securityType:[self securityType]];
                }];
            } else {
                [self showInvalidInputMessage];
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
        case HEMWiFiSetupStepSetTimezone: {
            [self forceSensorDataUpload];
            break;
        }
        case HEMWiFiSetupStepForceDataUpload:
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

- (void)showErrorMessage:(NSString*)errorMessage withTitle:(NSString*)title {
    __weak typeof(self) weakSelf = self;
    [self stopActivityWithMessage:nil renableControls:YES success:NO completion:^{
        [weakSelf showMessageDialog:errorMessage
                              title:title
                              image:nil
                       withHelpPage:NSLocalizedString(@"help.url.slug.wifi-scan", nil)];
    }];
}

- (void)showInvalidInputMessage {
    NSString* message = nil;
    if ([self securityType] == SENWifiEndpointSecurityTypeWep) {
        message = NSLocalizedString(@"wifi.error.invalid-wep-key", nil);
    } else {
        message = NSLocalizedString(@"wifi.error.invalid-input", nil);
    }
    [self showMessageDialog:message
                      title:NSLocalizedString(@"wifi.error.title", nil)
                      image:nil
               withHelpPage:NSLocalizedString(@"help.url.slug.wifi-scan", nil)];
}

- (void)showSetWiFiError:(NSError*)error {
    NSString* title = NSLocalizedString(@"wifi.error.title", nil);
    NSString* message = nil;

    switch ([error code]) {
        case SENSenseManagerErrorCodeWifiNotInRange:
            if ([self securityType] == SENWifiEndpointSecurityTypeWep) {
                message = NSLocalizedString(@"wifi.error.wep.no-ascii", nil);
            } else {
                message = NSLocalizedString(@"wifi.error.set-sense-not-in-range", nil);
            }
            break;
        case SENSenseManagerErrorCodeTimeout:
            message = NSLocalizedString(@"wifi.error.set-sense-timeout", nil);
            break;
        case SENSenseManagerErrorCodeWLANConnection:
        case SENSenseManagerErrorCodeFailToObtainIP:
            if ([self securityType] == SENWifiEndpointSecurityTypeWep) {
                message = NSLocalizedString(@"wifi.error.wep.no-ascii", nil);
            } else {
                message = NSLocalizedString(@"wifi.error.set-sense-failed-connection", nil);
            }
            break;
        default:
            message = NSLocalizedString(@"wifi.error.set-sense-general", nil);
            break;
    }

    [self showErrorMessage:message withTitle:title];
}

- (void)showLinkAccountError:(NSError*)error {
    NSString* title = NSLocalizedString(@"wifi.error.link-account-title", nil);
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

    [self showErrorMessage:message withTitle:title];
}

#pragma mark - Cleanup

- (void)dealloc {
    if (_disconnectObserverId != nil) {
        [[self manager] removeUnexpectedDisconnectObserver:_disconnectObserverId];
    }
}

@end
