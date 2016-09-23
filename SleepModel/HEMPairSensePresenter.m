//
//  HEMPairSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/BLE.h>

#import "HEMPairSensePresenter.h"
#import "HEMAlertViewController.h"
#import "HEMOnboardingService.h"
#import "HEMDeviceService.h"
#import "HEMActivityCoverView.h"
#import "HEMScreenUtils.h"
#import "HEMStyle.h"

static CGFloat const HEMPairSenseDescTopMarginAdjustment = 10.0f;
static CGFloat const HEMPairSenseIllustrationHeightAdjustment = 40.0f;
static NSUInteger const HEMPairSenseAttemptsBeforeWiFiChangeOption = 2;

typedef NS_ENUM(NSInteger, HEMPairSenseState) {
    HEMPairSenseStateNotStarted = 0,
    HEMPairSenseStateFound,
    HEMPairSenseStatePaired,
    HEMPairSenseStateSettingUpNewSense,
    HEMPairSenseStateWiFiNotDetected,
    HEMPairSenseStateWiFiDetected,
    HEMPairSenseStateIssuedSwapIntent,
    HEMPairSenseStateAccountLinked,
    HEMPairSenseStateTimezoneSet,
    HEMPairSenseStateForceDataUpload,
    HEMPairSenseStateChangeWiFiRequested
};

@interface HEMPairSensePresenter()

@property (nonatomic, weak) HEMOnboardingService* onbService;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) NSLayoutConstraint* descTopConstraint;
@property (nonatomic, assign) HEMPairSenseState currentState;
@property (nonatomic, assign) NSInteger linkAccountAttempts;
@property (nonatomic, copy) NSString* detectedSSID;
@property (nonatomic, weak) UIView* activityContainerView;
@property (nonatomic, strong) HEMActivityCoverView* activityCoverView;

@end

@implementation HEMPairSensePresenter

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService
                            deviceService:(HEMDeviceService*)deviceService {
    self = [super init];
    if (self) {
        _deviceService = deviceService;
        _onbService = onbService;
        _linkAccountAttempts = 0;
        _currentState = HEMPairSenseStateNotStarted;
    }
    return self;
}

- (void)bindWithActivityContainerView:(UIView*)activityContainerView {
    [self setActivityContainerView:activityContainerView];
}

- (void)bindWithNotGlowingButton:(UIButton*)button {
    [button setTitle:NSLocalizedString(@"onboarding.pair-sense.not-glowing", nil)
            forState:UIControlStateNormal];
    [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont button]];
    [button addTarget:self action:@selector(showWhyNotGlowing) forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithNextButton:(UIButton*)button {
    [button setTitle:[NSLocalizedString(@"actions.continue", nil) uppercaseString]
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(startPairing)
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    UIBarButtonItem* item =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"helpIconSmall"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(help)];
    [navItem setRightBarButtonItem:item];
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel
  descriptionTopConstraint:(NSLayoutConstraint*)topConstraint {
    [titleLabel setText:NSLocalizedString(@"onboarding.pair-sense.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"onboarding.pair-sense.desc", nil)];
    
    if (HEMIsIPhone4Family()) {
        CGFloat constant = [topConstraint constant];
        [topConstraint setConstant:constant + HEMPairSenseDescTopMarginAdjustment];
    }
}

- (void)bindWithIllustrationView:(__unused UIImageView*)illustrationView
             andHeightConstraint:(NSLayoutConstraint*)heightConstraint {
    if (HEMIsIPhone4Family()) {
        CGFloat constant = [heightConstraint constant];
        [heightConstraint setConstant:constant + HEMPairSenseIllustrationHeightAdjustment];
    }
}

- (void)trackEvent:(NSString*)event properties:(NSDictionary*)props {
    BOOL onboarding = [[self onbService] hasFinishedOnboarding];
    [SENAnalytics track:event properties:props onboarding:onboarding];
}

#pragma mark - State Machine

- (void)executeNextStep {
    switch ([self currentState]) {
        case HEMPairSenseStateNotStarted:
            return [self scanWithActivity];
        case HEMPairSenseStateFound:
            return [self pair];
        case HEMPairSenseStatePaired:
            return [self checkWiFi];
        case HEMPairSenseStateWiFiNotDetected:
            return [self proceed];
        case HEMPairSenseStateWiFiDetected:
            if ([self isUpgrading]) {
                [self issueSwapIntent];
            } else {
                [self linkAccount];
            }
            return;
        case HEMPairSenseStateIssuedSwapIntent:
            return [self linkAccount];
        case HEMPairSenseStateAccountLinked:
            return [self setTimeZone];
        case HEMPairSenseStateTimezoneSet:
            return [self forceSensorDataUpload];
        case HEMPairSenseStateForceDataUpload:
            [self saveCheckpointIfNeeded];
            return [self proceed];
        case HEMPairSenseStateChangeWiFiRequested:
            [self setDetectedSSID:nil];
            return [self justProceed];
        default: {
            DDLogWarn(@"state %ld not recognized", (long)[self currentState]);
            return;
        }
    }
}

- (void)saveCheckpointIfNeeded {
    if (![[self onbService] hasFinishedOnboarding]) {
        [[self onbService] saveOnboardingCheckpoint:HEMOnboardingCheckpointSenseDone];
    }
}

#pragma mark - Time Zone

- (void)setTimeZone {
    __weak typeof(self) weakSelf = self;
    DDLogVerbose(@"setting timezone");
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.setting-timezone", nil);
    [self updateActivityText:activityMessage completion:nil];
    [[self onbService] setTimeZone:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf setCurrentState:HEMPairSenseStateTimezoneSet];
            [strongSelf executeNextStep];
        } else {
            DDLogVerbose(@"failed to set time zone");
            NSString* msg = NSLocalizedString(@"pairing.error.set-timezone-failed", nil);
            [strongSelf showErrorMessage:msg];
        }
    }];
}

#pragma mark - BLE

- (void)scanWithActivity {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    BOOL preScanned = [service foundNearbySenses];
    
    NSString* activityMessage
        = preScanned
        ? NSLocalizedString(@"pairing.activity.connecting-sense", nil)
        : NSLocalizedString(@"pairing.activity.scanning-sense", nil);
    
    [self showActivityWithMessage:activityMessage completion:^{
        if (preScanned) {
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:[service nearestSense]];
            [service useTempSenseManager:manager];
            [service clearNearbySensesCache];
            [self setCurrentState:HEMPairSenseStateFound];
            [self executeNextStep];
        } else {
            // if a Sense has been found and the peripheral connected, disconnect from it
            // first to avoid causing issues when atttempting the process
            [[self onbService] disconnectCurrentSense];
            
            __weak typeof(self) weakSelf = self;
            HEMOnboardingService* service = [HEMOnboardingService sharedService];
            [service rescanForNearbySenseNotMatching:[self deviceIdsToExclude] completion:^(NSError * _Nullable error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (error) {
                    if ([[strongSelf activityCoverView] isShowing]) {
                        [[strongSelf activityCoverView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                            [strongSelf setActivityCoverView:nil];
                            [strongSelf showCouldNotPairErrorMessage];
                        }];
                    }
                    [strongSelf stopActivityWithMessage:nil success:NO completion:^{
                        [strongSelf showCouldNotPairErrorMessage];
                    }];
                } else {
                    [strongSelf setCurrentState:HEMPairSenseStateFound];
                    [strongSelf executeNextStep];
                }
            }];
        }
    }];
}

- (void)pair {
    __weak typeof(self) weakSelf = self;
    
    SENSense* currentSense = [[[self onbService] currentSenseManager] sense];
    DDLogVerbose(@"pairing with sense %@", [currentSense name]);
    
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.pairing-sense", nil);
    [self updateActivityText:activityMessage completion:nil];
    [[self onbService] pairWithCurrentSenseWithLEDOn:YES completion:^(NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf failPairing];
        } else {
            [strongSelf setCurrentState:HEMPairSenseStatePaired];
            [strongSelf executeNextStep];
        }
    }];
}

- (void)checkWiFi {
    __weak typeof(self) weakSelf = self;
    
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.checking-wifi", nil);
    [self updateActivityText:activityMessage completion:nil];
    [self setDetectedSSID:nil]; // nil it out in case this was detected in a previous run
    [[self onbService] checkIfCurrentSenseHasWiFi:^(NSString * ssid, BOOL connected, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        HEMPairSenseState pairState = HEMPairSenseStateWiFiNotDetected;
        if (ssid && connected) {
            DDLogVerbose(@"Sense connected to %@", ssid);
            pairState = HEMPairSenseStateWiFiDetected;
            [strongSelf setDetectedSSID:ssid];
        }
        [strongSelf setCurrentState:pairState];
        [strongSelf executeNextStep];
    }];
}

- (void)issueSwapIntent {
    __weak typeof(self) weakSelf = self;
    
    DDLogVerbose(@"issuing swap intent");
    [SENAnalytics track:HEMAnalyticsEventUpgradeSwapRequest];
    
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.linking-account", nil);
    [self updateActivityText:activityMessage completion:nil];
    
    SENSense* currentSense = [[[self onbService] currentSenseManager] sense];
    [[self deviceService] issueSwapIntentFor:currentSense completion:^(NSError * error) {
         __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [SENAnalytics track:HEMAnalyticsEventUpgradeSwapped];
            [strongSelf setCurrentState:HEMPairSenseStateIssuedSwapIntent];
            [strongSelf executeNextStep];
        } else {
            [strongSelf showSwapError:error];
        }
    }];
}

- (void)linkAccount {
    __weak typeof(self) weakSelf = self;
    
    DDLogVerbose(@"linking account");
    
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.linking-account", nil);
    if (![[[[self activityCoverView] activityLabel] text] isEqualToString:activityMessage]) {
        [self updateActivityText:activityMessage completion:nil];
    }
    
    [[self onbService] linkCurrentAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf trackEvent:HEMAnalyticsEventSensePaired properties:nil];
            [strongSelf setCurrentState:HEMPairSenseStateAccountLinked];
            [strongSelf executeNextStep];
        } else {
            NSUInteger attempts = [strongSelf linkAccountAttempts];
            [strongSelf setLinkAccountAttempts:attempts + 1];
            
            BOOL allowWiFiEdit = attempts + 1 >= HEMPairSenseAttemptsBeforeWiFiChangeOption;
            [strongSelf showLinkAccountError:allowWiFiEdit];
        }
    }];
}

- (void)forceSensorDataUpload {
    DDLogVerbose(@"forcing Sense to upload sensor data now");
    __weak typeof(self) weakSelf = self;
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    [service forceSensorDataUploadFromSense:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"data upload response returned with error? %@", error);
        [strongSelf setCurrentState:HEMPairSenseStateForceDataUpload];
        [strongSelf executeNextStep];
    }];
}

#pragma mark - Activity

- (void)showActivityWithMessage:(NSString*)message completion:(void(^)(void))completion {
    if ([self activityCoverView] != nil) {
        [[self activityCoverView] removeFromSuperview];
    }
    
    [self setActivityCoverView:[HEMActivityCoverView new]];
    [[self activityCoverView] showInView:[self activityContainerView]
                                withText:message
                                activity:YES
                              completion:completion];
}

- (void)updateActivityText:(NSString*)updateMessage completion:(void(^)(BOOL finished))completion {
    if (![self activityCoverView]) {
        if ([updateMessage length] > 0) {
            [self showActivityWithMessage:updateMessage completion:^{
                if (completion) completion (YES);
            }];
        } else if (completion) {
            completion (YES);
        }
    } else {
        [[self activityCoverView] updateText:updateMessage completion:completion];
    }
}

- (void)stopActivityWithMessage:(NSString*)message
                        success:(BOOL)sucess
                     completion:(void(^)(void))completion {
    
    if (![[self activityCoverView] isShowing]) {
        if (completion) {
            completion ();
        }
    } else {
        [[self activityCoverView] dismissWithResultText:message showSuccessMark:sucess remove:YES completion:^{
            [self setActivityCoverView:nil];
            if (completion) {
                completion ();
            }
        }];
    }
}

- (void)stopActivityBefore:(void(^)(void))action {
    __weak typeof(self) weakSelf = self;
    if ([[self onbService] currentSenseManager]) {
        [[self onbService] resetLED:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf stopActivityWithMessage:nil success:NO completion:action];
        }];
    } else {
        [self stopActivityWithMessage:nil success:NO completion:action];
    }
}

#pragma mark - Errors

- (void)showSwapError:(NSError*)error {
    __weak typeof(self) weakSelf = self;
    [self stopActivityBefore:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString* title = NSLocalizedString(@"pairing.failed.title", nil);
        NSString* message = NSLocalizedString(@"pairing.error.link-account-failed", nil);
        [[strongSelf errorDelegate] showErrorWithTitle:title
                                            andMessage:message
                                          withHelpPage:nil
                                         fromPresenter:strongSelf];
    }];
}

- (void)showLinkAccountError:(BOOL)allowWiFiEdit {
    __weak typeof(self) weakSelf = self;
    [self stopActivityBefore:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString* title = NSLocalizedString(@"pairing.failed.title", nil);
        if (allowWiFiEdit) {
            [strongSelf showEditWifiDialogWithTitle:title];
        } else {
            [strongSelf showLinkAccountFailedDialogWithTitle:title];
        }
    }];
}

- (void)showEditWifiDialogWithTitle:(NSString *)title {
    if ([[self errorDelegate] respondsToSelector:@selector(showCustomerAlert:fromPresenter:)]) {
        NSString *message = NSLocalizedString(@"pairing.error.link-account-failed-edit-wifi", nil);
        HEMAlertViewController *dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
        [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.ok", nil) style:HEMAlertViewButtonStyleRoundRect action:nil];
        [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.edit.wifi", nil) style:HEMAlertViewButtonStyleBlueText action:^{
            [self setCurrentState:HEMPairSenseStateChangeWiFiRequested];
            [self executeNextStep];
        }];
        [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
    }
}

- (void)showLinkAccountFailedDialogWithTitle:(NSString *)title {
    if ([[self errorDelegate] respondsToSelector:@selector(showCustomerAlert:fromPresenter:)]) {
        NSString* message = NSLocalizedString(@"pairing.error.link-account-failed", nil);
        __weak typeof(self) weakSelf = self;
        HEMAlertViewController *dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
        [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.ok", nil) style:HEMAlertViewButtonStyleRoundRect action:nil];
        [dialogVC addButtonWithTitle:NSLocalizedString(@"dialog.help.title", nil)
                               style:HEMAlertViewButtonStyleBlueText
                              action:^{
                                  NSString* helpPage = NSLocalizedString(@"help.url.slug.sense-pairing", nil);
                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                  [[strongSelf actionDelegate] showHelpWithPage:helpPage fromPresenter:strongSelf];
                              }];
        [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
    }
}

- (void)failPairing {
    [self setCurrentState:HEMPairSenseStateNotStarted]; // reset
    [[self onbService] useTempSenseManager:nil];
    [self showCouldNotPairErrorMessage];
}

- (void)showErrorMessage:(NSString*)message {
    __weak typeof(self) weakSelf = self;
    [self stopActivityBefore:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString* title = NSLocalizedString(@"pairing.failed.title", nil);
        NSString* page = NSLocalizedString(@"help.url.slug.sense-pairing", nil);
        [[strongSelf errorDelegate] showErrorWithTitle:title
                                            andMessage:message
                                          withHelpPage:page
                                         fromPresenter:strongSelf];
    }];
}

- (void)showCouldNotPairErrorMessage {
    [self showErrorMessage:NSLocalizedString(@"pairing.error.could-not-pair", nil)];
}

#pragma mark - Actions

- (void)help {
    NSString* page = NSLocalizedString(@"help.url.slug.pairing-sense-over-ble", nil);
    [[self actionDelegate] showHelpWithPage:page fromPresenter:self];
}

- (void)showWhyNotGlowing {
    NSString* page = NSLocalizedString(@"help.url.slug.sense-pairing-mode", nil);
    [[self actionDelegate] showHelpWithPage:page fromPresenter:self];
}

- (void)startPairing {
    [self setCurrentState:HEMPairSenseStateNotStarted];
    [self executeNextStep];
}

- (void)proceed {
    // need to do this to stop the activity and set the LED simultaneously or
    // else the LED does not properly sync up with the success mark
    //
    // FIXME: once firmware fixes the Success LED state, we should set it to success
    // when delegate exists, but since it doesn't work, it will leave the led to
    // an activity state
    __weak typeof(self) weakSelf = self;
    [[self onbService] resetLED:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf justProceed];
    }];
    
    NSString* msg = NSLocalizedString(@"pairing.done", nil);
    [self stopActivityWithMessage:msg success:YES completion:nil];
}

- (void)justProceed {
    [[self actionDelegate] didPairWithSenseWithCurrentSSID:[self detectedSSID]
                                             fromPresenter:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_onbService) {
        [_onbService stopObservingDisconnectsIfNeeded];
    }
}

@end
