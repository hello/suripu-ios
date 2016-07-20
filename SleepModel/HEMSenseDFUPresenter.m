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
#import "HEMStyle.h"

@interface HEMSenseDFUPresenter()

@property (nonatomic, weak) HEMOnboardingService* onboardingService;
@property (nonatomic, weak) UIButton* updateButton;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, weak) UILabel* statusLabel;

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
    
    if (updating) {
        [[self activityIndicator] start];
    } else {
        [[self activityIndicator] stop];
    }
    // always switch to retry after done
    NSString* retryText = [NSLocalizedString(@"actions.retry", nil) uppercaseString];
    [[self updateButton] setTitle:retryText forState:UIControlStateNormal];
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

- (void)showUpdateError:(__unused NSError*)error {
    [self showUpdatingState:NO];
    NSString* title = NSLocalizedString(@"onboarding.sense.dfu.error.title", nil);
    NSString* message = NSLocalizedString(@"onboarding.sense.dfu.error.generic", nil);
    [[self errorDelegate] showErrorWithTitle:title
                                  andMessage:message
                                withHelpPage:nil
                               fromPresenter:self];
}

#pragma mark - Actions

- (void)update {
    [self showUpdatingState:YES];
    
    __weak typeof(self) weakSelf = self;
    [[self onboardingService] forceSenseToUpdateFirmware:^(SENDFUStatus* status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf statusLabel] setText:[strongSelf textForStatus:status]];
    } completion:^(NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showUpdateError:error];
        } else {
            [[strongSelf dfuDelegate] senseUpdateCompletedFrom:strongSelf];
        }
    }];
}

@end
