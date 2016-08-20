//
//  HEMSenseDFUPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 7/19/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENDFUStatus.h>

#import "HEMSenseDFUPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMActivityCoverView.h"
#import "HEMStyle.h"

static CGFloat const HEMSenseDFUUpdatedMessageDuration = 2.0f;

@interface HEMSenseDFUPresenter()

@property (nonatomic, weak) HEMOnboardingService* onboardingService;
@property (nonatomic, weak) UIButton* updateButton;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, weak) UILabel* statusLabel;
@property (nonatomic, weak) UIButton* laterButton;
@property (nonatomic, strong) SENDFUStatus* previousStatus;

@end

@implementation HEMSenseDFUPresenter

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService {
    self = [super init];
    if (self) {
        _onboardingService = onbService;
    }
    return self;
}

- (void)bindWithUpdateButton:(UIButton*)updateButton {
    [updateButton addTarget:self
                   action:@selector(update)
         forControlEvents:UIControlEventTouchUpInside];
    [self setUpdateButton:updateButton];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicator
                      statusLabel:(UILabel*)statusLabel {
    // hide, until update is started
    [indicator stop];
    [indicator setHidden:YES];
    [statusLabel setHidden:YES];
    [statusLabel setFont:[UIFont h5]];
    [statusLabel setTextColor:[UIColor grey6]];
    [self setStatusLabel:statusLabel];
    [self setActivityIndicator:indicator];
}

- (void)showUpdatingState:(BOOL)updating {
    [[self updateButton] setHidden:updating];
    [[self activityIndicator] setHidden:!updating];
    [[self statusLabel] setHidden:!updating];
    [[self laterButton] setHidden:updating];
    
    if (updating) {
        [[self activityIndicator] start];
    } else {
        [[self activityIndicator] stop];
    }
    // always switch to retry after done
    NSString* retryText = [NSLocalizedString(@"actions.retry", nil) uppercaseString];
    [[self updateButton] setTitle:retryText forState:UIControlStateNormal];
}

- (void)bindWithLaterButton:(UIButton*)laterButton {
    [laterButton setHidden:YES];
    [laterButton addTarget:self
                    action:@selector(updateLater)
          forControlEvents:UIControlEventTouchUpInside];
    [self setLaterButton:laterButton];
}

#pragma mark - Status

- (NSString*)textForStatus:(SENDFUStatus*)status {
    switch ([status currentState]) {
        case SENDFUStateInProgress:
            return NSLocalizedString(@"onboarding.sense.dfu.status.in-progress", nil);
        default:
            return NSLocalizedString(@"onboarding.sense.dfu.status.sent", nil);
    }
}

#pragma mark - Errors

- (void)showUpdateError:(NSError*)error {
    [self showUpdatingState:NO];
    
    NSString* title = nil;
    NSString* message = nil;
    
    if ([[error domain] isEqualToString:NSURLErrorDomain]
        && [error code] == NSURLErrorNotConnectedToInternet) {
        title = NSLocalizedString(@"error.no-connection.title", nil);
        message = NSLocalizedString(@"error.no-connection", nil);
    } else {
        title = NSLocalizedString(@"onboarding.sense.dfu.error.title", nil);
        message = NSLocalizedString(@"onboarding.sense.dfu.error.generic", nil);
    }
    
    [[self errorDelegate] showErrorWithTitle:title
                                  andMessage:message
                                withHelpPage:nil
                               fromPresenter:self];
}

#pragma mark - Actions

- (void)update {
    [self showUpdatingState:YES];
    
    [SENAnalytics track:HEMAnalyticsEventSenseDFUBegin
             properties:nil
             onboarding:[self onboarding]];
    
    __weak typeof(self) weakSelf = self;
    [[self onboardingService] forceSenseToUpdateFirmware:^(SENDFUStatus* status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([[strongSelf previousStatus] currentState] != [status currentState]) {
            [SENAnalytics trackSenseUpdate:status];
        }
        [[strongSelf statusLabel] setText:[strongSelf textForStatus:status]];
        [strongSelf setPreviousStatus:status];
    } completion:^(NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showUpdateError:error];
        } else {
            [SENAnalytics track:HEMAnalyticsEventSenseDFUEnd
                     properties:nil
                     onboarding:[self onboarding]];
            [strongSelf finish];
        }
    }];
}

- (void)finish {
    BOOL voiceAvailable = [[self onboardingService] isVoiceAvailable];
    if (!voiceAvailable) {
        return [[self dfuDelegate] senseUpdateCompletedFrom:self];
    }
    
    UIView* parentView = [[self dfuDelegate] parentContentViewFor:self];
    NSString* updatedMessage = NSLocalizedString(@"onboarding.sense.dfu.updated", nil);
    
    HEMActivityCoverView* updatedView = [HEMActivityCoverView new];
    [updatedView showInView:parentView
                    withText:updatedMessage
                 successMark:YES
                  completion:^{
                      [[self dfuDelegate] senseUpdateCompletedFrom:self];
                      int64_t delay = (int64_t) (HEMSenseDFUUpdatedMessageDuration*NSEC_PER_SEC);
                      dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay);
                      dispatch_after(time, dispatch_get_main_queue(), ^{
                          [updatedView dismissWithResultText:nil
                                             showSuccessMark:NO
                                                      remove:YES
                                                  completion:nil];
                      });
                  }];
    
}

- (void)updateLater {
    NSString* title = NSLocalizedString(@"onboarding.sense.dfu.later.dialog.title", nil);
    NSString* message = NSLocalizedString(@"onboarding.sense.dfu.later.dialog.message", nil);
    
    __weak typeof(self) weakSelf = self;
    [[self dfuDelegate] showConfirmationWithTitle:title message:message okAction:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf dfuDelegate] senseUpdateLaterFrom:strongSelf];
    } cancelAction:nil from:self];
}

@end
