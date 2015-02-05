//
//  HEMEnablePushViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/9/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAPIPreferences.h>
#import <SenseKit/SENPreference.h>
#import "HEMEnablePushViewController.h"
#import "HEMActionButton.h"
#import "UIFont+HEMStyle.h"
#import "HEMOnboardingUtils.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMNotificationHandler.h"
#import "HEMBaseController+Protected.h"

@interface HEMEnablePushViewController()

@property (weak, nonatomic) IBOutlet HEMActionButton *enableButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraint;

@end

@implementation HEMEnablePushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableBackButton:NO];
    [SENAnalytics track:kHEMAnalyticsEventOnBNotification];
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    [self updateConstraint:[self imageTopConstraint] withDiff:-20];
}

#pragma mark - Actions

- (IBAction)enableNotifications:(id)sender {
    [HEMNotificationHandler registerForRemoteNotifications];
    [self enableNotificationsInPreferences];
    [self next];
}

- (IBAction)skip:(id)sender {
    [self next];
}

- (void)enableNotificationsInPreferences {
    SENPreference* conditionsPref = [[SENPreference alloc] initWithName:SENPreferenceNamePushConditions
                                                                  value:@(YES)];
    SENPreference* scorePref = [[SENPreference alloc] initWithName:SENPreferenceNamePushScore
                                                             value:@(YES)];
    [SENAPIPreferences updatePreference:conditionsPref completion:NULL];
    [SENAPIPreferences updatePreference:scorePref completion:NULL];
}

#pragma mark -

- (void)next {
    [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard pushToAudioSegueIdentifier]
                              sender:self];
}

@end
