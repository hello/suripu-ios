//
//  HEMPairPiillPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/16/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>

#import "UIBarButtonItem+HEMNav.h"

#import "HEMPairPiillPresenter.h"
#import "HEMOnboardingService.h"
#import "HEMEmbeddedVideoView.h"
#import "HEMActivityCoverView.h"
#import "HEMAlertViewController.h"
#import "HEMActionButton.h"
#import "HEMStyle.h"

static NSInteger const kHEMPairPillAttemptsBeforeSkip = 2;
static CGFloat const kHEMPairPillAnimDuration = 0.5f;

@interface HEMPairPiillPresenter()

@property (nonatomic, weak) HEMOnboardingService* onboardingService;
@property (nonatomic, weak) HEMEmbeddedVideoView* videoView;
@property (nonatomic, weak) HEMActivityCoverView* activityView;
@property (nonatomic, weak) UILabel* statusLabel;
@property (nonatomic, weak) HEMActionButton* continueButton;
@property (nonatomic, weak) NSLayoutConstraint* continueWidthConstraint;
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;
@property (nonatomic, assign, getter=isPairing) BOOL pairing;
@property (nonatomic, assign, getter=isCancellable) BOOL cancellable;
@property (nonatomic, assign) NSInteger pairingAttempts;
@property (nonatomic, copy) NSString* errorTitle;
@property (nonatomic, weak) UIButton* skipButton;
@property (nonatomic, weak) UIView* contentview;

@end

@implementation HEMPairPiillPresenter

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onboardingService {
    self = [super init];
    if (self) {
        _onboardingService = onboardingService;
        _errorTitle = NSLocalizedString(@"pairing.pill.error.title", nil);
        _analyticsHelpEventName = kHEMAnalyticsEventOnBHelp;
    }
    return self;
}

- (void)bindWithContentContainerView:(UIView*)contentView {
    [self setContentview:contentView];
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel {
    [titleLabel setText:NSLocalizedString(@"onboarding.pill.pair.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"onboarding.pill.pair.description", nil)];
}

- (void)bindWithStatusLabel:(UILabel*)statusLabel {
    [statusLabel setTextColor:[UIColor tintColor]];
    [statusLabel setText:NSLocalizedString(@"pairing.activity.looking-for-pill", nil)];
    [statusLabel setAlpha:0.0f];
    [self setStatusLabel:statusLabel];
}

- (void)bindWithContinueButton:(HEMActionButton*)continueButton
           withWidthConstraint:(NSLayoutConstraint*)widthConstraint {
    [continueButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateDisabled];
    [continueButton setBackgroundColor:[UIColor tintColor] forState:UIControlStateNormal];
    [continueButton addTarget:self
                       action:@selector(startPairing)
             forControlEvents:UIControlEventTouchUpInside];
    [self setContinueButton:continueButton];
    [self setContinueWidthConstraint:widthConstraint];
}

- (void)bindWithSkipButton:(UIButton*)skipButton {
    [skipButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[skipButton titleLabel] setFont:[UIFont button]];
    [skipButton addTarget:self
                   action:@selector(skip)
         forControlEvents:UIControlEventTouchUpInside];
    [self setSkipButton:skipButton];
}

- (void)bindWithEmbeddedVideoView:(HEMEmbeddedVideoView*)embeddedView {
    UIImage* image = [UIImage imageNamed:@"pairing_your_sleep_pill"];
    NSString* videoPath = NSLocalizedString(@"video.url.onboarding.pill-pair", nil);
    [embeddedView setFirstFrame:image videoPath:videoPath];
    [self setVideoView:embeddedView];
}

- (void)bindWithActivityView:(HEMActivityCoverView*)activityView {
    NSString* text = NSLocalizedString(@"pairing.activity.waiting-for-sense", nil);
    [[activityView activityLabel] setText:text];
    [self setActivityView:activityView];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem cancellable:(BOOL)cancellable {
    [navItem setRightBarButtonItem:[UIBarButtonItem helpButtonWithTarget:self action:@selector(help)]];
    if (cancellable) {
        [self setCancellable:YES];
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [navItem setLeftBarButtonItem:[UIBarButtonItem cancelItemWithTitle:cancel
                                                                     image:nil
                                                                    target:self
                                                                    action:@selector(cancel)]];
    }
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    if (![self isLoaded]) {
        if (![[self videoView] isReady]) {
            [[self videoView] setReady:YES];
        }
        [[self activityView] showActivity];
        [self startPairing];
        [self setLoaded:YES];
    } else if ([self isPairing]) {
        [[self videoView] playVideoWhenReady];
    }
}

- (void)didDisappear {
    [super didDisappear];
    [[self videoView] stop];
}

#pragma mark - Controls

- (void)setPairing:(BOOL)pairing {
    _pairing = pairing;
    
    if (pairing) {
        [[self videoView] playVideoWhenReady];
        [[self continueButton] setEnabled:NO];
        [[self continueButton] setTitleColor:[UIColor tintColor]
                                 forState:UIControlStateNormal];
        [[self continueButton] showActivityWithWidthConstraint:[self continueWidthConstraint]];
    } else {
        [[self videoView] stop];
        BOOL onboarding = ![[self onboardingService] hasFinishedOnboarding];
        [[self skipButton] setHidden:[self pairingAttempts] < kHEMPairPillAttemptsBeforeSkip
                                         || !onboarding];
        [[self continueButton] setEnabled:YES];
        [[self continueButton] setTitleColor:[UIColor whiteColor]
                                 forState:UIControlStateNormal];
        [[self continueButton] stopActivity];
    }
    
    CGFloat statusLabelAlpha = !pairing ? 0.0f : 1.0f;
    CGFloat skipButtonAlpha = !pairing ? 1.0f : 0.0f;
    [UIView animateWithDuration:kHEMPairPillAnimDuration animations:^{
        [[self statusLabel] setAlpha:statusLabelAlpha];
        [[self skipButton] setAlpha:skipButtonAlpha];
    }];
}

#pragma mark - Errors

- (void)showErrorMessage:(NSString*)message {
    [self setPairing:NO];
    [[self errorDelegate] showErrorWithTitle:[self errorTitle]
                                  andMessage:message
                                withHelpPage:nil
                               fromPresenter:self];
}

- (NSString*)errorMessageForError:(NSError*)error {
    if ([[error domain] isEqualToString:HEMOnboardingErrorDomain]) {
        switch ([error code]) {
                // TODO: handle other cases
            default:
                return NSLocalizedString(@"pairing.error.pill-pairing-failed", nil);
        }
    } else {
        switch ([error code]) {
            case SENSenseManagerErrorCodeInvalidated:
            case SENSenseManagerErrorCodeConnectionFailed:
            case SENSenseManagerErrorCodeCannotConnectToSense:
                return NSLocalizedString(@"pairing.error.could-not-pair", nil);
            case SENSenseManagerErrorCodeSenseAlreadyPaired:
                return NSLocalizedString(@"pairing.error.pill-already-paired", nil);
            case SENSenseManagerErrorCodeSenseNetworkError:
                return NSLocalizedString(@"pairing.error.pill-pairing-no-network", nil);
            case SENSenseManagerErrorCodeTimeout:
            default:
                return NSLocalizedString(@"pairing.error.pill-pairing-failed", nil);
        }
    }
}

#pragma mark - Actions

- (void)startPairing {
    [self setPairing:YES];
    [self setPairingAttempts:[self pairingAttempts] + 1];
    
    if ([self pairingAttempts] > 1) {
        BOOL onboarding = ![[self onboardingService] hasFinishedOnboarding];
        [SENAnalytics track:HEMAnalyticsEventPairPillRetry properties:nil onboarding:onboarding];
    }
    
    __weak typeof(self) weakSelf = self;
    void(^begin)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf onboardingService] ensurePairedSenseIsReady:^(NSError * _Nullable error) {
            if (error) {
                NSString* message = NSLocalizedString(@"pairing.error.sense-not-found", nil);
                [strongSelf showErrorMessage:message];
            } else {
                [strongSelf pairNow];
            }
        }];
    };
    
    if (![[self activityView] isShowing]) {
        NSString* text = NSLocalizedString(@"pairing.activity.waiting-for-sense", nil);
        [[self activityView] showWithText:text activity:YES completion:begin];
    } else {
        begin();
    }
}

- (void)pairNow {
    __weak typeof(self) weakSelf = self;
    [[self onboardingService] spinTheLEDs:^(NSError * error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:NO completion:^{
            if (error) {
                NSString* message = [strongSelf errorMessageForError:error];
                [strongSelf showErrorMessage:message];
            } else {
                [[strongSelf onboardingService] pairPill:^(NSError * error) {
                    if (error) {
                        [[strongSelf onboardingService] resetLED:^(NSError * ledError) {
                            NSString* message = [strongSelf errorMessageForError:error ?: ledError];
                            [strongSelf showErrorMessage:message];
                            if (ledError) {
                                [SENAnalytics trackError:ledError
                                           withEventName:kHEMAnalyticsEventWarning];
                            }
                        }];
                    } else {
                        [SENAnalytics track:HEMAnalyticsEventPillPaired];
                        [strongSelf flashPairedState];
                    }
                }];
            }
        }];
    }];
}

- (void)skip {
    NSString *title = NSLocalizedString(@"pairing.pill.skip-confirmation-title", nil);
    NSString *message = NSLocalizedString(@"pairing.pill.skip-confirmation-message", nil);
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    __weak typeof(self) weakSelf = self;
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.skip-for-now", nil) style:HEMAlertViewButtonStyleRoundRect action:^{
        __strong typeof(weakSelf) strongSelf = self;
        BOOL onboarding = ![[strongSelf onboardingService] hasFinishedOnboarding];
        NSDictionary* props = @{kHEMAnalyticsEventPropOnBScreen :kHEMAnalyticsEventPropScreenPillPairing};
        [SENAnalytics track:HEMAnalyticsEventSkip properties:props onboarding:onboarding];
        
        [[strongSelf onboardingService] saveOnboardingCheckpoint:HEMOnboardingCheckpointPillFinished];
        [[strongSelf onboardingService] disconnectCurrentSense];
        [[strongSelf delegate] completePairing:YES fromPresenter:strongSelf];
    }];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.cancel", nil) style:HEMAlertViewButtonStyleBlueText action:nil];
    
    [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
}

- (void)help {
    NSString* step = kHEMAnalyticsEventPropPillPairing;
    NSDictionary* properties = @{kHEMAnalyticsEventPropStep : step};
    [SENAnalytics track:[self analyticsHelpEventName] properties:properties];
    [[self delegate] showHelpPage:NSLocalizedString(@"help.url.slug.pill-pairing", nil)
                    fromPresenter:self];
}

- (void)cancel {
    [[self delegate] completePairing:YES fromPresenter:self];
}

#pragma mark - Completion

- (void)flashPairedState {
        NSString* paired = NSLocalizedString(@"pairing.done", nil);
        [[self activityView] showInView:[self contentview] withText:paired activity:NO completion:^{
            [self finish:YES];
        }];
}

- (void)finish:(BOOL)skipped {
    BOOL finishedOnboarding = [[self onboardingService] hasFinishedOnboarding];
    
    [[self onboardingService] notifyOfPillPairingChange];
    [[self onboardingService] disconnectCurrentSense];

    [[self activityView] dismissWithResultText:nil
                               showSuccessMark:YES
                                        remove:!finishedOnboarding
                                    completion:nil];
    
    if (!finishedOnboarding) {
        [[self onboardingService] saveOnboardingCheckpoint:HEMOnboardingCheckpointPillFinished];
    }
    
    [[self delegate] completePairing:NO fromPresenter:self];
}

@end
