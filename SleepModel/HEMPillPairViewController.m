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

#import "HEMPillPairViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingCache.h"
#import "HEMSettingsTableViewController.h"
#import "HEMOnboardingUtils.h"
#import "HEMSupportUtil.h"
#import "HelloStyleKit.h"
#import "HEMBluetoothUtils.h"
#import "HEMDialogViewController.h"

static CGFloat const kHEMPillPairAnimDuration = 0.5f;
static NSInteger const kHEMPillPairAttemptsBeforeSkip = 2;
static NSInteger const kHEMPillPairMaxBleChecks = 10;

@interface HEMPillPairViewController()

@property (weak, nonatomic) IBOutlet HEMActionButton *retryButton;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retryButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

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
    [self configureActivityLabel];
    
    if ([self delegate] == nil) {
        [SENAnalytics track:kHEMAnalyticsEventOnBPairPill];
    }
}

- (void)configureActivityLabel {
    [[self activityLabel] setTextColor:[HelloStyleKit senseBlueColor]];
    [[self activityLabel] setText:nil];
}

- (void)configureButtons {
    [[self skipButton] setTitleColor:[HelloStyleKit senseBlueColor]
                            forState:UIControlStateNormal];
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    
    [self showRetryButtonAsRetrying:YES];
    
    [self showHelpButtonAndTrackWithStepName:kHEMAnalyticsEventPropPillPairing];
    
    if ([self delegate] != nil) {
        [self showCancelButtonWithSelector:@selector(cancel:)];
    } else {
        [self enableBackButton:NO];
    }
}

- (void)showRetryButtonAsRetrying:(BOOL)retrying {
    if (retrying) {
        [[self retryButton] setBackgroundColor:[UIColor clearColor]];
        [[self retryButton] setTitleColor:[HelloStyleKit senseBlueColor]
                                 forState:UIControlStateNormal];
        [[self retryButton] showActivityWithWidthConstraint:[self retryButtonWidthConstraint]];
    } else {
        [[self retryButton] setBackgroundColor:[HelloStyleKit senseBlueColor]];
        [[self retryButton] setTitleColor:[HelloStyleKit actionButtonTextColor]
                                 forState:UIControlStateNormal];
        [[self retryButton] stopActivity];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self isLoaded]) {
        [self showActivityWithMessage:NSLocalizedString(@"pairing.activity.waiting-for-sense", nil) completion:^{
            [self enableControls:NO];
            [self pairPill:self];
        }];
        [self setLoaded:YES];
    }
}

- (void)enableControls:(BOOL)enable {
    [[self cancelItem] setEnabled:enable];
    [self showRetryButtonAsRetrying:!enable];
    [[self skipButton] setHidden:!enable
                                 && ([self pairAttempts] < kHEMPillPairAttemptsBeforeSkip
                                    || [self delegate] != nil)];

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
                __block typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
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
            
            [strongSelf stopActivityWithMessage:nil success:NO completion:^{
                NSString* msg = NSLocalizedString(@"pairing.error.fail-to-load-paired-info", nil);
                [strongSelf showError:error customMessage:msg];
                completion (nil);
            }];
            
            return;
        }
        
        DDLogVerbose(@"looking for sense to trigger pill pairing");
        [[SENServiceDevice sharedService] scanForPairedSense:^(NSError *error) {
            [strongSelf stopActivityWithMessage:nil success:NO completion:^{
                if (error != nil) {
                    NSString* msg = NSLocalizedString(@"pairing.error.sense-not-found", nil);
                    [strongSelf showError:error customMessage:msg];
                    completion (nil);
                    return;
                }
                completion ([[SENServiceDevice sharedService] senseManager]);
            }];
        }];
    }];
}

- (IBAction)pairPill:(id)sender {
    [self enableControls:NO];
    [self setPairAttempts:[self pairAttempts] + 1];
    
    __weak typeof(self) weakSelf = self;
    [self ensureSenseIsReady:^(SENSenseManager *manager) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (manager == nil) {
            [strongSelf stopActivityWithMessage:nil success:NO completion:^{
                [strongSelf showError:nil customMessage:NSLocalizedString(@"pairing.error.sense-not-found", nil)];
            }];
        } else {
            [strongSelf pairNowWith:manager];
        }
    }];
}

- (void)pairNowWith:(SENSenseManager*)manager {
    [self listenForDisconnects];
    
    [[self activityLabel] setText:NSLocalizedString(@"pairing.activity.looking-for-pill", nil)];
    
    __weak typeof(self) weakSelf = self;
    [manager setLED:SENSenseLEDStateActivity completion:^(id response, NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"attempting to pair pill through %@", [[[strongSelf manager] sense] name]);
        [strongSelf stopActivityWithMessage:nil success:NO completion:^{ // if activity is not shown, it will simply call blocck
            [[strongSelf manager] pairWithPill:[SENAuthorizationService accessToken] success:^(id response) {
                [strongSelf flashPairedState];
            } failure:^(NSError *error) {
                SENSenseLEDState ledState = [strongSelf delegate] == nil ? SENSenseLEDStatePair : SENSenseLEDStateOff;
                [[strongSelf manager] setLED:ledState completion:^(id response, NSError *error) {
                    [strongSelf showError:error customMessage:nil];
                }];
            }];
        }];
    }];
}

- (void)flashPairedState {
    NSString* paired = NSLocalizedString(@"pairing.done", nil);
    [self showActivityWithMessage:paired completion:^{
        [[self cancelItem] setEnabled:YES];
        
        [self stopActivityWithMessage:nil success:YES completion:nil];
        
        SENSenseLEDState ledState = [self delegate] == nil ? SENSenseLEDStatePair : SENSenseLEDStateOff;
        __weak typeof(self) weakSelf = self;
        [[self manager] setLED:ledState completion:^(id response, NSError *error) {
            [weakSelf proceed];
        }];
    }];
}

#pragma mark - Skipping

- (IBAction)skip:(id)sender {
    [self showSkipConfirmation];
}

- (void)showSkipConfirmation {
    HEMDialogViewController* dialogVC = [[HEMDialogViewController alloc] init];
    [dialogVC setTitle:NSLocalizedString(@"pairing.pill.skip-confirmation-title", nil)];
    [dialogVC setMessage:NSLocalizedString(@"pairing.pill.skip-confirmation-message", nil)];
    [dialogVC setOkButtonTitle:[NSLocalizedString(@"actions.skip-for-now", nil) uppercaseString]];
    [dialogVC setViewToShowThrough:[[self navigationController] view]];
    
    [dialogVC addAction:[NSLocalizedString(@"actions.cancel", nil) uppercaseString] primary:NO actionBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [dialogVC showFrom:self onDone:^{
        [self dismissViewControllerAnimated:YES completion:^{
            [SENAnalytics track:kHEMAnalyticsEventOnBSkip properties:@{
                kHEMAnalyticsEventPropOnBScreen : kHEMAnalyticsEventPropScreenPillPairing
            }];
            
            [[self manager] setLED:SENSenseLEDStateOff completion:nil]; // fire and forget is ok here
            [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointPillDone];
            NSString* segueId = [HEMOnboardingStoryboard skipPillPairSegue];
            [self performSegueWithIdentifier:segueId sender:self];
        }];
    }];
}

- (void)cancel:(id)sender {
    [[self delegate] didCancelPairing:self];
}

#pragma mark - Next

- (void)proceed {
    if ([self delegate] == nil) {
        [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointPillDone];
        
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
            case SENSenseManagerErrorCodeTimeout:
            default:
                message = NSLocalizedString(@"pairing.error.pill-pairing-failed", nil);
                break;
        }
    }
    
    [self showMessageDialog:message
                      title:NSLocalizedString(@"pairing.pill.error.title", nil)
                      image:nil
                   withHelp:YES];
    
    [self enableControls:YES];
    
    if (error) {
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
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
