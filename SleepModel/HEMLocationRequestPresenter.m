//
//  HEMLocationRequestPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 6/7/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMLocationRequestPresenter.h"
#import "HEMLocationService.h"
#import "HEMOnboardingService.h"
#import "HEMActionButton.h"
#import "HEMStyle.h"

@interface HEMLocationRequestPresenter()

@property (nonatomic, weak) HEMLocationService* locService;
@property (nonatomic, weak) HEMOnboardingService* onbService;
@property (nonatomic, weak) HEMActionButton* locationButton;
@property (nonatomic, weak) UIButton* skipButton;
@property (nonatomic, strong) HEMLocationActivity* locationActivity;

@end

@implementation HEMLocationRequestPresenter

- (instancetype)initWithLocationService:(HEMLocationService*)locService
                   andOnboardingService:(HEMOnboardingService*)onboardingService {
    self = [super init];
    if (self) {
        _locService = locService;
        _onbService = onboardingService;
    }
    return self;
}

- (void)bindWithLocationButton:(HEMActionButton*)locationButton {
    [self setLocationButton:locationButton];
    [[self locationButton] addTarget:self
                              action:@selector(setLocation:)
                    forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithSkipButton:(UIButton*)skipButton {
    [self setSkipButton:skipButton];
    [[[self skipButton] titleLabel] setFont:[UIFont button]];
    [[self skipButton] addTarget:self
                          action:@selector(skip:)
                forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions

- (void)setLocation:(UIButton*)button {
    if ([self locationActivity]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[self locService] requestPermission:^(HEMLocationAuthStatus status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (status == HEMLocationAuthStatusAuthorized) {
            [strongSelf startLocationActivity];
        } else {
            NSString* title = NSLocalizedString(@"location.error.title", nil);
            NSString* message = nil;
            if (status == HEMLocationAuthStatusDenied) {
                message = NSLocalizedString(@"location.error.denied", nil);
            } else if (status == HEMLocationAuthStatusNotEnabled) {
                message = NSLocalizedString(@"location.error.not-enabled", nil);
            } else {
                message = NSLocalizedString(@"location.error.generic", nil);
            }
            [[strongSelf delegate] showAlertWithTitle:title message:message from:strongSelf];
        }
    }];
}

- (void)skip:(UIButton*)button {
    [self updateAccount:YES];
    [self trackPermission:YES error:nil];
    [[self delegate] proceedFrom:self];
}

#pragma mark - Location

- (void)trackPermission:(BOOL)skipped error:(NSError*)error {
    NSString* status = nil;
    
    if (skipped) {
        status = kHEManaltyicsEventStatusSkipped;
    } else if (error == nil) {
        status = kHEManaltyicsEventStatusEnabled;
    } else if ([error code] == HEMLocationErrorCodeDenied) {
        status = kHEManaltyicsEventStatusDenied;
    } else if ([error code] == HEMLocationErrorCodeNotEnabled) {
        status = kHEManaltyicsEventStatusDisabled;
    }
    
    NSDictionary* properties = status != nil ? @{kHEManaltyicsEventPropStatus : status} : nil;
    [SENAnalytics track:kHEMAnalyticsEventPermissionLoc properties:properties];
}

- (void)startLocationActivity {
    NSError* startError = nil;
    __weak typeof(self) weakSelf = self;
    self.locationActivity = [[self locService] startLocationActivity:^(HEMLocation * mostRecentLocation, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (mostRecentLocation) {
            SENAccount* account = [[HEMOnboardingService sharedService] currentAccount];
            [account setLatitude:@([mostRecentLocation lat])];
            [account setLongitude:@([mostRecentLocation lon])];
            [strongSelf trackPermission:NO error:nil];
        } else if (error) {
            [strongSelf trackPermission:NO error:error];
        }
        
        [strongSelf stopLocationActivity];
        
    } error:&startError];
    
    if (startError) {
        NSString* message = [self errorMessageForLocationError:startError];
        NSString* title = NSLocalizedString(@"location.error.title", nil);
        [[self delegate] showAlertWithTitle:title message:message from:self];
    } else if ([self locationActivity]) {
        [[self delegate] proceedFrom:self]; // optimistically obtain location and proceed
    }
}

- (void)stopLocationActivity {
    [[self locService] stopLocationActivity:[self locationActivity]];
    [self setLocationActivity:nil];
    [self updateAccount:YES];
}

#pragma mark - Account Update

- (void)updateAccount:(BOOL)retry {
    DDLogVerbose(@"updating account");
    __weak typeof(self) weakSelf = self;
    [[self onbService] updateCurrentAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            DDLogVerbose(@"update completed with error %@", error);
            if (retry) {
                DDLogVerbose(@"failed to update account with user information");
                [strongSelf updateAccount:NO];
            }
        }
    }];
}

#pragma mark - Errors

- (NSString*)errorMessageForLocationError:(NSError*)error {
    if ([[error domain] isEqualToString:HEMLocationErrorDomain]) {
        switch ([error code]) {
            case HEMLocationErrorCodeDenied:
                return NSLocalizedString(@"location.error.denied", nil);
            case HEMLocationErrorCodeNotEnabled:
                return NSLocalizedString(@"location.error.not-enabled", nil);
            default:
                return nil;
        }
    } else {
        return NSLocalizedString(@"location.error.weak-signal", nil);
    }
}

#pragma mark - Clean up

- (void)dealloc {
    if (_locationActivity && _locService) {
        [_locService stopLocationActivity:_locationActivity];
    }
}

@end
