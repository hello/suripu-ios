//
//  HEMBluetoothViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <SenseKit/BLE.h>
#import <SenseKit/SENAuthorizationService.h>

#import "UIFont+HEMStyle.h"

#import "HEMSensePairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingCache.h"
#import "HEMSettingsTableViewController.h"
#import "HEMOnboardingUtils.h"
#import "HEMActivityCoverView.h"
#import "HEMSecondPillCheckViewController.h"
#import "HelloStyleKit.h"
#import "HEMSupportUtil.h"
#import "HEMWifiPickerViewController.h"

typedef NS_ENUM(NSUInteger, HEMSensePairState) {
    HEMSensePairStateNotStarted = 0,
    HEMSensePairStateSenseFound = 1,
    HEMSensePairStateSensePaired = 2,
    HEMSensePairStatePairingError = 3,
    HEMSensePairStateAddingSleepPill = 4,
    HEMSensePairStateSettingUpNewSense = 5,
    HEMSensePairStateWiFiNotDetected = 6,
    HEMSensePairStateWiFiDetected = 7,
    HEMSensePairStateAccountLinked = 8,
    HEMSensePairStateForceDataUpload = 9
};

// I've tested the scanning process multiple times starting with a timeout of
// 15 to 20.  Out of say 5 tries, I've seen it return in time once.  30 secs
// seem to allow the response to return in time reliably.
static CGFloat const kHEMSensePairScanTimeout = 30.0f;

@interface HEMSensePairViewController() <HEMSecondPillCheckDelegate>

@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *senseImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *noSenseButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readyButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopConstraint;

@property (strong, nonatomic) UIBarButtonItem* cancelItem;
@property (strong, nonatomic) SENSenseManager* manager;
@property (assign, nonatomic) HEMSensePairState currentState;
@property (copy,   nonatomic) NSString* disconnectObserverId;
@property (copy,   nonatomic) NSString* detectedSSID;
@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (assign, nonatomic, getter=isTimedOut) BOOL timedOut;
@property (assign, nonatomic, getter=isPairing) BOOL pairing;
@property (assign, nonatomic, getter=hasAskedAboutSecondPill) BOOL askedAboutSecondPill;

@end

@implementation HEMSensePairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDescription];
    [self showHelpButton];
    [self setupCancelButton];
    [self setCurrentState:HEMSensePairStateNotStarted];
    
    if ([self delegate] == nil) {
        [SENAnalytics track:kHEMAnalyticsEventOnBPairSense];
    }
}

- (void)setupCancelButton {
    if ([self delegate] != nil) {
        NSString* title = NSLocalizedString(@"actions.cancel", nil);
        UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:cancelItem];
        [self setCancelItem:cancelItem];
    }
}

- (void)setupDescription {
    NSString* desc = NSLocalizedString(@"sense-pair.description", nil);
    
    NSMutableAttributedString* attrDesc = [[NSMutableAttributedString alloc] initWithString:desc];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrDesc];
    
    [[self descLabel] setAttributedText:attrDesc];
}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self imageHeightConstraint] withDiff:-66];
    [self updateConstraint:[self imageTopConstraint] withDiff:20];
    [self updateConstraint:[self descriptionTopConstraint] withDiff:10];
}

- (void)stopActivityWithMessage:(NSString*)message success:(BOOL)sucess completion:(void(^)(void))completion {
    [[self activityView] dismissWithResultText:message showSuccessMark:sucess remove:YES completion:^{
        [[self noSenseButton] setEnabled:YES];
        if (completion) completion ();
    }];
}

- (void)cacheManager {
    [[HEMOnboardingCache sharedCache] setSenseManager:[self manager]];
}

- (void)disconnectSense {
    if ([self manager] != nil) {
        if ([self disconnectObserverId] != nil) {
            [[self manager] removeUnexpectedDisconnectObserver:[self disconnectObserverId]];
            [self setDisconnectObserverId:nil];
        }
        [[self manager] disconnectFromSense];
    }
}

- (void)observeUnexpectedDisconnects {
    __weak typeof(self) weakSelf = self;
    self.disconnectObserverId =
        [[self manager] observeUnexpectedDisconnect:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf stopActivityWithMessage:nil success:NO completion:^{
                    if ([strongSelf isPairing]) {
                        [strongSelf setCurrentState:HEMSensePairStatePairingError];
                        [strongSelf executeNextStep];
                    } else {
                        NSString* message = NSLocalizedString(@"pairing.error.unexpected-disconnect", nil);
                        [strongSelf showErrorMessage:message];
                    }
                }];
            }
        }];
}

#pragma mark - Actions

- (void)cancel:(id)sender {
    [[self delegate] didPairSense:NO from:self];
}

- (IBAction)enablePairing:(id)sender {
    // restart the scanning
    [self setCurrentState:HEMSensePairStateNotStarted];
    [self executeNextStep];
}

- (IBAction)help:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    [HEMSupportUtil openHelpFrom:self];
}

#pragma mark - Scanning

- (BOOL)preScannedSensesFound {
    return [[[HEMOnboardingCache sharedCache] nearbySensesFound] count] > 0;
}

- (void)scanTimeout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanTimeout) object:nil];
    DDLogVerbose(@"scanning for Sense timed out, oh no!");
    [self setTimedOut:YES];
    [SENSenseManager stopScan];
    [self stopActivityWithMessage:nil success:NO completion:^{
        NSString* msg = NSLocalizedString(@"pairing.error.timed-out", nil);
        [self showErrorMessage:msg];
    }];
    [SENAnalytics track:kHEMAnalyticsEventError
             properties:@{kHEMAnalyticsEventPropMessage : @"scanning timed out"}];
}

- (void)scanWithActivity {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    
    [self setTimedOut:NO];
    [[self noSenseButton] setEnabled:NO];
    
    BOOL preScanned = [self preScannedSensesFound];
    
    NSString* activityMessage
        = preScanned
        ? NSLocalizedString(@"pairing.activity.connecting-sense", nil)
        : NSLocalizedString(@"pairing.activity.scanning-sense", nil);
    
    UIView* viewToAttach = [[self navigationController] view];
    [[self activityView] showInView:viewToAttach withText:activityMessage activity:YES completion:^{
        if (preScanned) {
            [self useSense:[[[HEMOnboardingCache sharedCache] nearbySensesFound] firstObject]];
            [[HEMOnboardingCache sharedCache] clearPreScannedSenses];
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
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(scanTimeout) object:nil];
            
            if ([senses count] > 0) {
                // per team consensus, it is expected that the app pairs with the
                // first sense with the highest average RSSI value that is found.
                // In our case, the first object matches that spec.
                [strongSelf useSense:[senses firstObject]];
            } else {
                [SENAnalytics track:kHEMAnalyticsEventError
                         properties:@{kHEMAnalyticsEventPropMessage : @"no sense found"}];
                
                [strongSelf stopActivityWithMessage:nil success:NO completion:^{
                    [strongSelf setCurrentState:HEMSensePairStatePairingError];
                    [strongSelf executeNextStep];
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
    DDLogVerbose(@"using sense %@", [[self manager] sense]);
    [self setManager:[[SENSenseManager alloc] initWithSense:sense]];
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
        case HEMSensePairStatePairingError: {
            if ([self hasAskedAboutSecondPill]) {
                NSString* msg = NSLocalizedString(@"pairing.error.could-not-pair", nil);
                [self showErrorMessage:msg];
            } else {
                [self checkIfAddingSecondPill];
            }
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
            [self forceSensorDataUpload];
            break;
        }
        case HEMSensePairStateForceDataUpload: {
            if ([self delegate] == nil) {
                [[HEMOnboardingCache sharedCache] startPollingSensorData];
                [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointSenseDone];
            }
            [self finish];
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
    [self setPairing:YES];
    [self observeUnexpectedDisconnects];
    
    __weak typeof(self) weakSelf = self;
    // led will be turned off when everything is finished, failed or not
    [[self manager] setLED:SENSenseLEDStateActivity completion:^(id response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString* activityMessage = NSLocalizedString(@"pairing.activity.pairing-sense", nil);
        [[strongSelf activityView] updateText:activityMessage completion:nil];
        DDLogVerbose(@"pairing with sense %@", [[[strongSelf manager] sense] name]);
        
        [[strongSelf manager] pair:^(id response) {
            DDLogVerbose(@"paired!");
            if (strongSelf && ![strongSelf isTimedOut]) {
                [strongSelf setPairing:NO];
                [strongSelf cacheManager];
                [strongSelf setCurrentState:HEMSensePairStateSensePaired];
                [strongSelf executeNextStep];
            }
        } failure:^(NSError *error) {
            DDLogVerbose(@"failed to pair %@", error);
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf setPairing:NO];
                [strongSelf stopActivityWithMessage:nil success:NO completion:^{
                    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                    [strongSelf setCurrentState:HEMSensePairStatePairingError];
                    [strongSelf executeNextStep];
                }];
            }
        }];
    }];
}

#pragma mark - WiFi

- (void)checkWiFi {
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.checking-wifi", nil);
    [[self activityView] updateText:activityMessage completion:nil];
    DDLogVerbose(@"checking if Sense has already been configured with wifi");
    
    __weak typeof(self) weakSelf = self;
    [[self manager] getConfiguredWiFi:^(NSString *ssid, SENWiFiConnectionState state) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            HEMSensePairState pairState = HEMSensePairStateWiFiNotDetected;
            if (state == SENWiFiConnectionStateConnected) {
                pairState = HEMSensePairStateWiFiDetected;
                [strongSelf setDetectedSSID:ssid];
            }
            if ([ssid length] > 0) {
                [HEMOnboardingUtils saveConfiguredSSID:ssid];
            }
            DDLogVerbose(@"wifi %@ is in state detected %ld", ssid, (long)state);
            [strongSelf setCurrentState:pairState];
            [strongSelf executeNextStep];
        }
    } failure:^(NSError *error) {
        DDLogVerbose(@"could not determine configured wifi ssid + state");
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
        
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            // if there's an error just act like wifi was not set up, rather than
            // telling user that wifi could not be checked and making user do
            // something that makes no sense
            [strongSelf setCurrentState:HEMSensePairStateWiFiNotDetected];
            [strongSelf executeNextStep];
        }
    }];
}

#pragma mark - Second Pill

- (void)checkIfAddingSecondPill {
    __weak typeof(self) weakSelf = self;
    [[self manager] setLED:SENSenseLEDStatePair completion:^(id response, NSError *error) {
        DDLogVerbose(@"asking if user has a second pill to set up");
        [weakSelf performSegueWithIdentifier:[HEMOnboardingStoryboard secondPillCheckSegueIdentifier]
                                      sender:weakSelf];
    }];
}

#pragma mark - Link Account

- (void)linkAccount {
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.linking-account", nil);
    [[self activityView] updateText:activityMessage completion:nil];
    DDLogVerbose(@"linking account");
    
    NSString* accessToken = [SENAuthorizationService accessToken];
    SENSenseManager* manager = [self manager];
    
    __weak typeof(self) weakSelf = self;
    [manager linkAccount:accessToken success:^(id response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setCurrentState:HEMSensePairStateAccountLinked];
            [strongSelf executeNextStep];
        }
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf stopActivityWithMessage:nil success:NO completion:^{
                NSString* msg = NSLocalizedString(@"pairing.error.link-account-failed", nil);
                [strongSelf showErrorMessage:msg];
            }];
        }
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    }];
}

#pragma mark - Data Upload

- (void)forceSensorDataUpload {
    __weak typeof(self) weakSelf = self;
    [[self manager] forceDataUpload:^(id response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            DDLogVerbose(@"failed to upload data %@", error);
        }
        
        // whether there was an error or not, simply proceed b/c it's not
        // required that the data is uploaded
        [strongSelf setCurrentState:HEMSensePairStateForceDataUpload];
        [strongSelf executeNextStep];
    }];
}

#pragma mark - Errors

- (void)showErrorMessage:(NSString*)message {
    __weak typeof(self) weakSelf = self;
    [[self manager] setLED:SENSenseLEDStatePair completion:^(id response, NSError *error) {
        [weakSelf showMessageDialog:message
                              title:NSLocalizedString(@"pairing.failed.title", nil)
                              image:nil
                           withHelp:YES];
    }];
}

#pragma mark - Finishing

- (void)finish {
    NSString* msg = NSLocalizedString(@"pairing.done", nil);
    __block BOOL ledSet = NO;
    __block BOOL activityStopped = NO;
    __weak typeof(self) weakSelf = self;
    
    // need to do this to stop the activity and set the LED simultaneously or
    // else the LED does not properly sync up with the success mark
    void(^done)(void) = ^{
        if (activityStopped && ledSet) {
            [weakSelf next];
        }
    };
    
    [self stopActivityWithMessage:msg success:YES completion:^{
        activityStopped = YES;
        done();
    }];
    
    [[self manager] setLED:SENSenseLEDStateSuccess completion:^(id response, NSError *error) {
        [[weakSelf manager] setLED:SENSenseLEDStatePair completion:^(id response, NSError *error) {
            ledSet = YES;
            done();
        }];
    }];
}

- (void)next {
    if ([self delegate] == nil) {
        NSString* segueId = nil;
        if ([self detectedSSID] != nil) {
            DDLogVerbose(@"detected SSID %@, skipping wifi set up", [self detectedSSID]);
            segueId = [HEMOnboardingStoryboard senseToPillSegueIdentifier];
        } else {
            segueId = [HEMOnboardingStoryboard wifiSegueIdentifier];
        }
        [self performSegueWithIdentifier:segueId sender:self];
    } else {
        [[self delegate] didPairSense:YES from:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* destVC = segue.destinationViewController;
    if ([[segue identifier] isEqualToString:[HEMOnboardingStoryboard secondPillCheckSegueIdentifier]]) {
        UINavigationController* nav = (UINavigationController*)destVC;
        [[nav navigationBar] setTintColor:[HelloStyleKit senseBlueColor]];
        HEMSecondPillCheckViewController* pairingCheckVC = (HEMSecondPillCheckViewController*)[nav topViewController];
        [pairingCheckVC setDelegate:self];
    } else if ([destVC isKindOfClass:[HEMWifiPickerViewController class]]) {
        HEMWifiPickerViewController* pickerVC = (HEMWifiPickerViewController*)destVC;
        [pickerVC setSensePairDelegate:[self delegate]]; // if one is set, pass it along
    }
}

#pragma mark - HEMPairingCheckDelegate

- (void)checkController:(HEMSecondPillCheckViewController *)controller
    isSettingUpNewSense:(BOOL)settingUpNewSense {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self setAskedAboutSecondPill:YES];
        if (!settingUpNewSense) {
            // restart the process
            [self setCurrentState:HEMSensePairStateNotStarted];
        }
        [self executeNextStep];
    }];
}

#pragma mark - Clean up

- (void)dealloc {
    [SENSenseManager stopScan];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
