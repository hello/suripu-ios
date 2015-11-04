//
//  HEMPillPairViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENSense.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceDevice.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMPillPairViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSettingsTableViewController.h"
#import "HEMSupportUtil.h"
#import "HEMBluetoothUtils.h"
#import "HEMAlertViewController.h"
#import "HEMActivityCoverView.h"
#import "HEMEmbeddedVideoView.h"

static CGFloat const kHEMPillPairAnimDuration = 0.5f;
static NSInteger const kHEMPillPairAttemptsBeforeSkip = 2;
static NSInteger const kHEMPillPairMaxBleChecks = 10;

@interface HEMPillPairViewController()

@property (weak, nonatomic) IBOutlet HEMActivityCoverView *overlayActivityView;
@property (weak, nonatomic) IBOutlet HEMActionButton *retryButton;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retryButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet HEMEmbeddedVideoView *videoView;

@property (weak,   nonatomic) UIBarButtonItem* cancelItem;
@property (assign, nonatomic) BOOL pairTimedOut;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;
@property (assign, nonatomic) NSUInteger pairAttempts;
@property (assign, nonatomic) NSUInteger bleCheckAttempts;

@property (strong, nonatomic) id disconnectObserverId;

@end

@implementation HEMPillPairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureButtons];
    [self configureVideo];
    [self configureActivity];
    [self trackAnalyticsEvent:HEMAnalyticsEventPairPill];
}

- (void)configureVideo {
    NSString* videoPath = NSLocalizedString(@"video.url.onboarding.pill-pair", nil);
    [[self videoView] setVideoPath:videoPath];
}

- (void)configureActivity {
    [[self activityLabel] setTextColor:[UIColor tintColor]];
    [[self activityLabel] setText:nil];
    
    NSString* text = NSLocalizedString(@"pairing.activity.waiting-for-sense", nil);
    [[[self overlayActivityView] activityLabel] setText:text];
}

- (void)configureButtons {
    [[self skipButton] setTitleColor:[UIColor tintColor]
                            forState:UIControlStateNormal];
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    
    [self showRetryButtonAsRetrying:YES];
    
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.pill-pairing", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropPillPairing];
    
    if ([self delegate] != nil) {
        [self showCancelButtonWithSelector:@selector(cancel:)];
    } else {
        [self enableBackButton:NO];
    }
}

- (void)showRetryButtonAsRetrying:(BOOL)retrying {
    if (retrying) {
        [[self retryButton] setBackgroundColor:[UIColor clearColor]];
        [[self retryButton] setTitleColor:[UIColor tintColor]
                                 forState:UIControlStateNormal];
        [[self retryButton] showActivityWithWidthConstraint:[self retryButtonWidthConstraint]];
    } else {
        [[self retryButton] setBackgroundColor:[UIColor tintColor]];
        [[self retryButton] setTitleColor:[UIColor actionButtonTextColor]
                                 forState:UIControlStateNormal];
        [[self retryButton] stopActivity];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self isLoaded]) {
        if (![[self videoView] isReady]) {
            [[self videoView] setReady:YES];
        }
        [[self overlayActivityView] showActivity];
        [self setControlsEnabled:NO];
        [self pairPill:self];
        [self setLoaded:YES];
    } else {
        if ([[self retryButton] isShowingActivity]) {
            [[self videoView] playVideoWhenReady];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self videoView] stop];
}

- (void)setControlsEnabled:(BOOL)enable {
    [[self cancelItem] setEnabled:enable];
    [self showRetryButtonAsRetrying:!enable];
    [[self skipButton] setHidden:!enable
                                 || [self pairAttempts] < kHEMPillPairAttemptsBeforeSkip
                                 || [self delegate] != nil];

    CGFloat activityLabelAlpha = enable ? 0.0f : 1.0f;
    CGFloat skipButtonAlpha = enable ? 1.0f : 0.0f;
    [UIView animateWithDuration:kHEMPillPairAnimDuration animations:^{
        [[self activityLabel] setAlpha:activityLabelAlpha];
        [[self skipButton] setAlpha:skipButtonAlpha];
    }];
}

- (void)listenForDisconnects {
    SENSenseManager* manager = [self manager];
    if ([self disconnectObserverId] == nil && manager != nil) {
        __weak typeof(self) weakSelf = self;
        self.disconnectObserverId =
            [manager observeUnexpectedDisconnect:^(NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ([strongSelf isVisible]) {
                    NSString* msg = NSLocalizedString(@"pairing.error.unexpected-disconnect", nil);
                    [strongSelf showError:error customMessage:msg];
                }
            }];
    }
}

#pragma mark - Pairing

- (void)ensureSenseIsReady:(void(^)(SENSenseManager* manager))completion {
    if (!completion) return;
    
    SENSenseManager* manager = [self manager];
    if (manager != nil) {
        completion (manager);
    } else if (![HEMBluetoothUtils isBluetoothOn]) {
        if ([self bleCheckAttempts] < kHEMPillPairMaxBleChecks) {
            [self setBleCheckAttempts:[self bleCheckAttempts] + 1];
            [self performSelector:@selector(ensureSenseIsReady:) withObject:completion afterDelay:0.1f];
        } else {
            [self setBleCheckAttempts:0]; // reset it
            [self showError:nil customMessage:NSLocalizedString(@"pairing.activity.bluetooth-not-on", nil)];
        }
    } else {
        [self scanForPairedSense:completion];
    }
}

- (void)scanForPairedSense:(void(^)(SENSenseManager* manager))completion {
    
    __weak typeof(self) weakSelf = self;
    [[SENServiceDevice sharedService] loadDeviceInfo:^(NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            NSString* msg = NSLocalizedString(@"pairing.error.fail-to-load-paired-info", nil);
            [strongSelf showError:error customMessage:msg];
            completion (nil);
            return;
        }
        
        DDLogVerbose(@"looking for sense to trigger pill pairing");
        [[SENServiceDevice sharedService] scanForPairedSense:^(NSError *error) {
            if (error != nil) {
                NSString* msg = NSLocalizedString(@"pairing.error.sense-not-found", nil);
                [strongSelf showError:error customMessage:msg];
                completion (nil);
                return;
            }
            completion ([[SENServiceDevice sharedService] senseManager]);
        }];
    }];
}

- (IBAction)pairPill:(id)sender {
    [self setControlsEnabled:NO];
    [self setPairAttempts:[self pairAttempts] + 1];
    [[self videoView] playVideoWhenReady];
    
    if ([self pairAttempts] > 1) {
        [self trackAnalyticsEvent:HEMAnalyticsEventPairPillRetry];
    }
    
    __weak typeof(self) weakSelf = self;
    void(^begin)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf ensureSenseIsReady:^(SENSenseManager *manager) {
            if (manager == nil) {
                [strongSelf showError:nil customMessage:NSLocalizedString(@"pairing.error.sense-not-found", nil)];
            } else {
                [strongSelf pairNowWith:manager];
            }
        }];
    };
    
    if (![[self overlayActivityView] isShowing]) {
        NSString* text = NSLocalizedString(@"pairing.activity.waiting-for-sense", nil);
        [[self overlayActivityView] showWithText:text activity:YES completion:begin];
    } else {
        begin();
    }
}

- (void)pairNowWith:(SENSenseManager*)manager {
    [self listenForDisconnects];
    
    [[self activityLabel] setText:NSLocalizedString(@"pairing.activity.looking-for-pill", nil)];
    
    __weak typeof(self) weakSelf = self;
    [manager setLED:SENSenseLEDStateActivity completion:^(id response, NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            [strongSelf showError:error customMessage:nil];
            return;
        }
        
        [[strongSelf overlayActivityView] dismissWithResultText:nil showSuccessMark:NO remove:NO completion:^{
            [[strongSelf manager] pairWithPill:[SENAuthorizationService accessToken] success:^(id response) {
                [strongSelf flashPairedState];
            } failure:^(NSError *error) {
                SENSenseLEDState ledState = [strongSelf delegate] == nil ? SENSenseLEDStatePair : SENSenseLEDStateOff;
                [[strongSelf manager] setLED:ledState completion:^(id response, NSError *ledError) {
                    [strongSelf showError:error ?: ledError customMessage:nil];
                    if (error && ledError) {
                        // if there are errors from both, log the led error since showError: will
                        // show the error for pill pairing failure instead, which will log that
                        [SENAnalytics trackError:ledError withEventName:kHEMAnalyticsEventWarning];
                    }
                }];
            }];
        }];
    }];
}

- (void)flashPairedState {
    NSString* paired = NSLocalizedString(@"pairing.done", nil);
    [[self overlayActivityView] showWithText:paired activity:NO completion:^{
        [[self cancelItem] setEnabled:YES];
        
        [[self overlayActivityView] dismissWithResultText:nil showSuccessMark:YES remove:YES completion:nil];
        
        SENSenseLEDState ledState = [self delegate] == nil ? SENSenseLEDStatePair : SENSenseLEDStateOff;
        __weak typeof(self) weakSelf = self;
        [[self manager] setLED:ledState completion:^(id response, NSError *error) {
            if (error != nil) {
                [SENAnalytics trackWarningWithMessage:@"failed to set LED on Sense"];
            }
            [weakSelf proceed];
        }];

    }];
}

#pragma mark - Skipping

- (IBAction)skip:(id)sender {
    [self showSkipConfirmation];
}

- (void)showSkipConfirmation {
    NSString *title = NSLocalizedString(@"pairing.pill.skip-confirmation-title", nil);
    NSString *message = NSLocalizedString(@"pairing.pill.skip-confirmation-message", nil);
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    __weak typeof(self) weakSelf = self;
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.skip-for-now", nil) style:HEMAlertViewButtonStyleRoundRect action:^{
        __strong typeof(weakSelf) strongSelf = self;
        NSDictionary* props = @{kHEMAnalyticsEventPropOnBScreen :kHEMAnalyticsEventPropScreenPillPairing};
        [strongSelf trackAnalyticsEvent:HEMAnalyticsEventSkip properties:props];

        [[strongSelf manager] setLED:SENSenseLEDStateOff completion:nil]; // fire and forget is ok here
        [[HEMOnboardingService sharedService] saveOnboardingCheckpoint:HEMOnboardingCheckpointPillDone];
        NSString* segueId = [HEMOnboardingStoryboard skipPillPairSegue];
        [strongSelf performSegueWithIdentifier:segueId sender:strongSelf];
    }];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.cancel", nil) style:HEMAlertViewButtonStyleBlueText action:nil];
    [dialogVC setViewToShowThrough:[[self navigationController] view]];
    [dialogVC showFrom:self];
}

- (void)cancel:(id)sender {
    [[self delegate] didCancelPairing:self];
}

#pragma mark - Next

- (void)proceed {
    [[HEMOnboardingService sharedService] notifyOfPillPairingChange];
    
    if ([self delegate] == nil) {
        [[HEMOnboardingService sharedService] saveOnboardingCheckpoint:HEMOnboardingCheckpointPillDone];
        
        NSString* segueId = [HEMOnboardingStoryboard doneSegueIdentifier];
        [self performSegueWithIdentifier:segueId sender:self];
    } else {
        [[self delegate] didPairWithPillFrom:self];
    }
}

#pragma mark - Errors

- (void)showError:(NSError*)error customMessage:(NSString*)customMessage {
    NSString* message = customMessage;
    
    if (message == nil) {
        
        switch ([error code]) {
            case SENSenseManagerErrorCodeSenseAlreadyPaired:
                message = NSLocalizedString(@"pairing.error.pill-already-paired", nil);
                break;
            case SENSenseManagerErrorCodeSenseNetworkError:
                message = NSLocalizedString(@"pairing.error.pill-pairing-no-network", nil);
                break;
            case SENSenseManagerErrorCodeTimeout:
            default:
                message = NSLocalizedString(@"pairing.error.pill-pairing-failed", nil);
                break;
        }
    }
    
    [[self overlayActivityView] dismissWithResultText:nil showSuccessMark:NO remove:NO completion:^{
        
        [self showMessageDialog:message
                          title:NSLocalizedString(@"pairing.pill.error.title", nil)
                          image:nil
                   withHelpPage:NSLocalizedString(@"help.url.slug.pill-pairing", nil)];
        
        [self setControlsEnabled:YES];
        
    }];
    
    if (error) {
        [SENAnalytics trackError:error];
    }
}

#pragma mark - Clean Up

- (void)dealloc {
    if (_disconnectObserverId != nil) {
        SENSenseManager* manager = [self manager];
        [manager removeUnexpectedDisconnectObserver:_disconnectObserverId];
        [self setDisconnectObserverId:nil];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
