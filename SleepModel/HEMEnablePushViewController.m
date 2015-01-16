//
//  HEMEnablePushViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/9/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMEnablePushViewController.h"
#import "HEMActionButton.h"
#import "UIFont+HEMStyle.h"
#import "HEMOnboardingUtils.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMNotificationHandler.h"

@interface HEMEnablePushViewController()

@property (weak, nonatomic) IBOutlet HEMActionButton *enableButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation HEMEnablePushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableBackButton:NO];
    [SENAnalytics track:kHEMAnalyticsEventOnBNotification];
}

#pragma mark - Actions

- (IBAction)enableNotifications:(id)sender {
    [HEMNotificationHandler registerForRemoteNotifications];
    // don't wait before user to answer the dialog, just go
    [self next];
}

- (IBAction)skip:(id)sender {
    [self next];
}

#pragma mark -

- (void)next {
    [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard pushToAudioSegueIdentifier]
                              sender:self];
}

@end
