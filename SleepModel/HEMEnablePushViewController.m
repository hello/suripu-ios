//
//  HEMEnablePushViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/9/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAPIPreferences.h>
#import <SenseKit/SENPreference.h>

#import "Sense-Swift.h"

#import "HEMEnablePushViewController.h"
#import "HEMActionButton.h"
#import "UIFont+HEMStyle.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMEnablePushViewController()

@property (strong, nonatomic) PushNotificationService* pushService;
@property (weak, nonatomic) IBOutlet HEMActionButton *enableButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraint;

@end

@implementation HEMEnablePushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setPushService:[PushNotificationService new]];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventNotification];
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    [self updateConstraint:[self imageTopConstraint] withDiff:-20];
}

#pragma mark - Actions

- (IBAction)enableNotifications:(id)sender {
    if ([[self pushService] canRegisterForPushNotifications]) {
        [[UIApplication sharedApplication] askForPermissionToSendPushNotifications];
    }
    [self enableNotificationsInPreferences];
    [self next];
}

- (IBAction)skip:(id)sender {
    [self next];
}

- (void)enableNotificationsInPreferences {
    SENPreference* conditionsPref = [[SENPreference alloc] initWithName:SENPreferenceNamePushConditions
                                                                  value:@(YES)];
    [conditionsPref saveLocally];
    SENPreference* scorePref = [[SENPreference alloc] initWithName:SENPreferenceNamePushScore
                                                             value:@(YES)];
    [scorePref saveLocally];
    [SENAPIPreferences updatePreferencesWithCompletion:NULL];
}

#pragma mark -

- (void)next {
    [[HEMOnboardingService sharedService] saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard notificationToSenseSegueIdentifier]
                              sender:self];
}

@end
