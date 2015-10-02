//
//  HEMBluetoothViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <SenseKit/BLE.h>
#import <SenseKit/SENAPITimeZone.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMSensePairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingService.h"
#import "HEMSettingsTableViewController.h"
#import "HEMSupportUtil.h"
#import "HEMWifiPickerViewController.h"
#import "HEMAlertViewController.h"
#import "HEMEmbeddedVideoView.h"

typedef NS_ENUM(NSUInteger, HEMSensePairState) {
    HEMSensePairStateNotStarted = 0,
    HEMSensePairStateSenseFound = 1,
    HEMSensePairStateSensePaired = 2,
    HEMSensePairStateSettingUpNewSense = 3,
    HEMSensePairStateWiFiNotDetected = 4,
    HEMSensePairStateWiFiDetected = 5,
    HEMSensePairStateAccountLinked = 6,
    HEMSensePairStateTimezoneSet = 7,
    HEMSensePairStateForceDataUpload = 8,
    HEMSensePairStateNeedWiFiChange = 9
};

// I've tested the scanning process multiple times starting with a timeout of
// 15 to 20.  Out of say 5 tries, I've seen it return in time once.  30 secs
// seem to allow the response to return in time reliably.
static CGFloat const kHEMSensePairScanTimeout = 30.0f;
static NSUInteger const HEMSensePairAttemptsBeforeWiFiChangeOption = 2;

@interface HEMSensePairViewController()

@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *notGlowingButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopConstraint;

@property (strong, nonatomic) UIBarButtonItem* cancelItem;
@property (strong, nonatomic) SENSenseManager* senseManager;
@property (assign, nonatomic) HEMSensePairState currentState;
@property (copy,   nonatomic) NSString* disconnectObserverId;
@property (copy,   nonatomic) NSString* detectedSSID;
@property (assign, nonatomic, getter=isTimedOut) BOOL timedOut;
@property (assign, nonatomic, getter=isPairing) BOOL pairing;
@property (assign, nonatomic) NSUInteger linkAccountAttempts;

@end

@implementation HEMSensePairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureButtons];
    [self setCurrentState:HEMSensePairStateNotStarted];
    [self setLinkAccountAttempts:0];
    [self trackAnalyticsEvent:HEMAnalyticsEventPairSense];
}

- (void)configureButtons {
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.sense-pairing", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropSensePairing];
    [[self notGlowingButton] setTitleColor:[UIColor tintColor]
                                  forState:UIControlStateNormal];
    [[[self notGlowingButton] titleLabel] setFont:[UIFont secondaryButtonFont]];

    if ([self delegate] != nil) {
        [self showCancelButtonWithSelector:@selector(cancel:)];
    }
}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self descriptionTopConstraint] withDiff:10];
}

- (void)disconnectSense {
    if ([self senseManager] != nil) {
        if ([self disconnectObserverId] != nil) {
            [[self senseManager] removeUnexpectedDisconnectObserver:[self disconnectObserverId]];
            [self setDisconnectObserverId:nil];
        }
        [[self senseManager] disconnectFromSense];
        [self setSenseManager:nil];
    }
}

- (void)observeUnexpectedDisconnects {
    if ([self disconnectObserverId] == nil) {
        __weak typeof(self) weakSelf = self;
        self.disconnectObserverId =
        [[self senseManager] observeUnexpectedDisconnect:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setSenseManager:nil];
            if ([strongSelf isVisible]) {
                if ([strongSelf isPairing]) {
                    [strongSelf showCouldNotPairErrorMessage];
                } else {
                    NSString* message = NSLocalizedString(@"pairing.error.unexpected-disconnect", nil);
                    [strongSelf showErrorMessage:message];
                }
            }
        }];
    }
}

#pragma mark - Actions

- (void)cancel:(id)sender {
    [[self delegate] didPairSenseUsing:nil from:self];
}

- (IBAction)enablePairing:(id)sender {
    // restart the scanning
    [self setCurrentState:HEMSensePairStateNotStarted];
    [self executeNextStep];
}

#pragma mark - Scanning

- (void)scanTimeout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanTimeout) object:nil];
    DDLogVerbose(@"scanning for Sense timed out, oh no!");
    [self setTimedOut:YES];

    [SENSenseManager stopScan];
    [[self senseManager] disconnectFromSense];
    [self setSenseManager:nil];

    NSString* msg = NSLocalizedString(@"pairing.error.timed-out", nil);
    [self showErrorMessage:msg];

    [SENAnalytics trackErrorWithMessage:@"scanning timed out"];
}

- (void)scanWithActivity {
    [self setTimedOut:NO];

    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    BOOL preScanned = [service foundNearbySenses];

    NSString* activityMessage
        = preScanned
        ? NSLocalizedString(@"pairing.activity.connecting-sense", nil)
        : NSLocalizedString(@"pairing.activity.scanning-sense", nil);

    [self showActivityWithMessage:activityMessage completion:^{
        if (preScanned) {
            [self useSense:[service nearestSense]];
            [service clearNearbySensesCache];
        } else {
            [self startScan];
        }
    }];
}

- (void)startScan {
    // if a Sense has been found and the peripheral connected, disconnect from it
    // first to avoid causing issues when atttempting the process
    [self disconnectSense];

    [SENSenseManager stopScan]; // stop scanning in case one is already on it's way

    [self performSelector:@selector(scanTimeout)
               withObject:nil
               afterDelay:kHEMSensePairScanTimeout];

    __weak typeof(self) weakSelf = self;
    if (![SENSenseManager scanForSense:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && ![strongSelf isTimedOut]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf
                                                     selector:@selector(scanTimeout)
                                                       object:nil];

            if ([senses count] > 0) {
                // per team consensus, it is expected that the app pairs with the
                // first sense with the highest average RSSI value that is found.
                // In our case, the first object matches that spec.
                [strongSelf useSense:[senses firstObject]];
            } else {
                [SENAnalytics trackErrorWithMessage:@"no sense found"];

                [strongSelf stopActivityWithMessage:nil success:NO completion:^{
                    [strongSelf showCouldNotPairErrorMessage];
                }];

            }
        }
    }]) {
        DDLogVerbose(@"ble not ready, retrying");
        [self performSelector:@selector(startScan)
                   withObject:nil
                   afterDelay:0.1f];
    }
}

- (void)useSense:(SENSense*)sense {
    DDLogVerbose(@"using sense %@", [[self senseManager] sense]);
    [self setSenseManager:[[SENSenseManager alloc] initWithSense:sense]];
    [self setCurrentState:HEMSensePairStateSenseFound];
    [self executeNextStep];
}

#pragma mark - States

- (void)executeNextStep {
    switch ([self currentState]) {
        case HEMSensePairStateNotStarted: {
            [self scanWithActivity];
            break;
        }
        case HEMSensePairStateSenseFound: {
            [self pair];
            break;
        }
        case HEMSensePairStateSensePaired: {
            [self checkWiFi];
            break;
        }
        case HEMSensePairStateWiFiNotDetected: {
            [self finish];
            break;
        }
        case HEMSensePairStateWiFiDetected: {
            [self linkAccount];
            break;
        }
        case HEMSensePairStateAccountLinked: {
            [self setupTimeZone];
            break;
        }
        case HEMSensePairStateTimezoneSet: {
            [self forceSensorDataUpload];
            break;
        }
        case HEMSensePairStateForceDataUpload: {
            if ([self delegate] == nil) {
                HEMOnboardingService* service = [HEMOnboardingService sharedService];
                [service saveOnboardingCheckpoint:HEMOnboardingCheckpointSenseDone];
            }
            [self finish];
            break;
        }
        case HEMSensePairStateNeedWiFiChange: {
            [self setDetectedSSID:nil];
            [self next];
            break;
        }
        default: {
            DDLogWarn(@"state %ld not recognized", (long)[self currentState]);
            break;
        }
    }
}


#pragma mark - Pairing

- (void)pair {
    // make sure we set the sense Id as soon as user tries to pair so if there is
    // an error, we will know what device id it's for
    NSString* deviceId = [[[self senseManager] sense] deviceId];
    if (deviceId) {
        [SENAnalytics setUserProperties:@{kHEMAnalyticsEventPropSenseId : deviceId}];
    }

    [self setPairing:YES];
    [self observeUnexpectedDisconnects];

    __weak typeof(self) weakSelf = self;
    // led will be turned off when everything is finished, failed or not
    [[self senseManager] setLED:SENSenseLEDStateActivity completion:^(id response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            DDLogVerbose(@"showing led activity failed, stopping");
            [SENAnalytics trackError:error];
            [strongSelf failPairing];
            return;
        }

        NSString* activityMessage = NSLocalizedString(@"pairing.activity.pairing-sense", nil);
        [strongSelf updateActivityText:activityMessage completion:nil];
        DDLogVerbose(@"pairing with sense %@", [[[strongSelf senseManager] sense] name]);

        [[strongSelf senseManager] pair:^(id response) {
            DDLogVerbose(@"paired!");
            if (![strongSelf isTimedOut]) {
                HEMOnboardingService* service = [HEMOnboardingService sharedService];
                [service replaceCurrentSenseManagerWith:[strongSelf senseManager]];
                [strongSelf setPairing:NO];
                [strongSelf setCurrentState:HEMSensePairStateSensePaired];
                [strongSelf executeNextStep];
            }
        } failure:^(NSError *error) {
            DDLogVerbose(@"failed to pair %@", error);
            [SENAnalytics trackError:error];
            [strongSelf failPairing];
        }];
    }];
}

- (void)failPairing {
    [self setCurrentState:HEMSensePairStateNotStarted]; // reset
    [self disconnectSense];
    [self showCouldNotPairErrorMessage];
    [self setPairing:NO];
}

- (void)showCouldNotPairErrorMessage {
    NSString* msg = NSLocalizedString(@"pairing.error.could-not-pair", nil);
    [self showErrorMessage:msg];
}

#pragma mark - WiFi

- (void)checkWiFi {
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.checking-wifi", nil);
    [self updateActivityText:activityMessage completion:nil];
    DDLogVerbose(@"checking if Sense has already been configured with wifi");

    [self setDetectedSSID:nil]; // nil it out in case this was detected in a previous run

    __weak typeof(self) weakSelf = self;
    [[self senseManager] getConfiguredWiFi:^(NSString *ssid, SENSenseWiFiStatus* status) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        HEMSensePairState pairState = HEMSensePairStateWiFiNotDetected;
        if ([status isConnected]) {
            pairState = HEMSensePairStateWiFiDetected;
            [strongSelf setDetectedSSID:ssid];
        }
        if ([ssid length] > 0) {
            [[HEMOnboardingService sharedService] saveConfiguredSSID:ssid];
        }
        DDLogVerbose(@"wifi %@ with status %@", ssid, status);
        [strongSelf setCurrentState:pairState];
        [strongSelf executeNextStep];
    } failure:^(NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"could not determine configured wifi ssid + state");
        [SENAnalytics trackError:error];
        // if there's an error just act like wifi was not set up, rather than
        // telling user that wifi could not be checked and making user do
        // something that makes no sense
        [strongSelf setCurrentState:HEMSensePairStateWiFiNotDetected];
        [strongSelf executeNextStep];
    }];
}

#pragma mark - Link Account

- (void)linkAccount {
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.linking-account", nil);
    [self updateActivityText:activityMessage completion:nil];
    DDLogVerbose(@"linking account");

    __weak typeof(self) weakSelf = self;
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    [service linkCurrentAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf setCurrentState:HEMSensePairStateAccountLinked];
            [strongSelf executeNextStep];
        } else {
            NSUInteger attempts = [strongSelf linkAccountAttempts];
            [strongSelf setLinkAccountAttempts:attempts + 1];

            BOOL allowWiFiEdit = attempts + 1 >= HEMSensePairAttemptsBeforeWiFiChangeOption;
            [strongSelf showLinkAccountError:allowWiFiEdit];

            [SENAnalytics trackError:error];
        }
    }];
}

#pragma mark - Set Timezone

- (void)setupTimeZone {
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.setting-timezone", nil);
    [self updateActivityText:activityMessage completion:nil];
    DDLogVerbose(@"setting timezone");

    __weak typeof(self) weakSelf = self;
    [SENAPITimeZone setCurrentTimeZone:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil) {
            [strongSelf setCurrentState:HEMSensePairStateTimezoneSet];
            [strongSelf executeNextStep];
        } else {
            DDLogVerbose(@"failed to set time zone");
            NSString* msg = NSLocalizedString(@"pairing.error.set-timezone-failed", nil);
            [weakSelf showErrorMessage:msg];
            [SENAnalytics trackError:error];
        }
    }];
}

#pragma mark - Data Upload

- (void)forceSensorDataUpload {
    DDLogVerbose(@"forcing data upload from ui");
    __weak typeof(self) weakSelf = self;
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    [service forceSensorDataUploadFromSense:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"data upload response returned with error? %@", error);
        if (error != nil) {
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventWarning];
        }
        [strongSelf setCurrentState:HEMSensePairStateForceDataUpload];
        [strongSelf executeNextStep];
    }];
}

#pragma mark - Errors

- (void)stopActivityBefore:(void(^)(void))action {
    __weak typeof(self) weakSelf = self;
    void(^show)(id response, NSError* error) = ^(__unused id response, __unused NSError* error){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf stopActivityWithMessage:nil success:NO completion:action];
    };

    if ([self senseManager] == nil) {
        show(nil, nil);
    } else {
        SENSenseLEDState led = [self delegate] == nil ? SENSenseLEDStatePair : SENSenseLEDStateOff;
        [[self senseManager] setLED:led completion:show];
    }
}

- (void)showLinkAccountError:(BOOL)allowWiFiEdit {
    __weak typeof(self) weakSelf = self;
    [self stopActivityBefore:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIView* seeThroughView
            = [strongSelf parentViewController]
            ? [[strongSelf parentViewController] view]
            : [strongSelf view];

        NSString* title = NSLocalizedString(@"pairing.failed.title", nil);
        HEMAlertViewController* dialogVC = nil;

        if (allowWiFiEdit) {
            NSString* message = NSLocalizedString(@"pairing.error.link-account-failed-edit-wifi", nil);
            dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
            [dialogVC addAction:NSLocalizedString(@"actions.edit.wifi", nil) primary:NO actionBlock:^{
                [strongSelf setCurrentState:HEMSensePairStateNeedWiFiChange];
                [strongSelf executeNextStep];
            }];
        } else {
            NSString* message = NSLocalizedString(@"pairing.error.link-account-failed", nil);
            dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
            [dialogVC setHelpPage:NSLocalizedString(@"help.url.slug.sense-pairing", nil)];
        }
        [dialogVC setViewToShowThrough:seeThroughView];
        [dialogVC showFrom:strongSelf onDefaultActionSelected:nil];
    }];
}

- (void)showErrorMessage:(NSString*)message {
    __weak typeof(self) weakSelf = self;
    [self stopActivityBefore:^{
        [weakSelf showMessageDialog:message
                              title:NSLocalizedString(@"pairing.failed.title", nil)
                              image:nil
                       withHelpPage:NSLocalizedString(@"help.url.slug.sense-pairing", nil)];
    }];
}

#pragma mark - Finishing

- (void)finish {
    // need to do this to stop the activity and set the LED simultaneously or
    // else the LED does not properly sync up with the success mark
    //
    // FIXME: once firmware fixes the Success LED state, we should set it to success
    // when delegate exists, but since it doesn't work, it will leave the led to
    // an activity state
    SENSenseLEDState led = [self delegate] == nil ? SENSenseLEDStatePair : SENSenseLEDStateOff;
    __weak typeof(self) weakSelf = self;
    [[self senseManager] setLED:led completion:^(id response, NSError *error) {
        [weakSelf next]; // once ble operation is done, proceed.  activity should hide after
    }];

    NSString* msg = NSLocalizedString(@"pairing.done", nil);
    [self stopActivityWithMessage:msg success:YES completion:nil];
}

- (void)next {
    [[HEMOnboardingService sharedService] notifyOfSensePairingChange];

    if ([self delegate] == nil) {
        NSString* segueId = nil;
        if ([self detectedSSID] != nil) {
            DDLogVerbose(@"detected SSID %@, skipping wifi set up", [self detectedSSID]);
            segueId = [HEMOnboardingStoryboard sensePairToPillSegueIdentifier];
        } else {
            segueId = [HEMOnboardingStoryboard wifiSegueIdentifier];
        }
        [self performSegueWithIdentifier:segueId sender:self];
    } else {
        if ([self detectedSSID] != nil) {
            [[HEMOnboardingService sharedService] clear];
            [[self delegate] didPairSenseUsing:[self senseManager] from:self];
        } else {
            [self performSegueWithIdentifier:[HEMOnboardingStoryboard wifiSegueIdentifier]
                                      sender:self];
        }

    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[HEMWifiPickerViewController class]]) {
        HEMWifiPickerViewController* pickerVC = (HEMWifiPickerViewController*)destVC;
        [pickerVC setSensePairDelegate:[self delegate]]; // if one is set, pass it along
    }
}

#pragma mark - Clean up

- (void)dealloc {
    [SENSenseManager stopScan];
    if (_disconnectObserverId != nil) {
        [_senseManager removeUnexpectedDisconnectObserver:_disconnectObserverId];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
