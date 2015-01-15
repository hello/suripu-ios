//
//  HEMOnboardAlarmViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAlarm.h>

#import "UIView+HEMSnapshot.h"
#import "UIFont+HEMStyle.h"

#import "HEMOnboardAlarmViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMScrollableView.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMAlarmViewController.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMOnboardAlarmViewController() <HEMAlarmControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation HEMOnboardAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [self enableBackButton:NO];
    [SENAnalytics track:kHEMAnalyticsEventOnBFirstAlarm];
}

- (void)dismissAlarmVC:(HEMAlarmViewController*)alarmVC {
    [self dismissViewControllerAnimated:NO completion:^{
        [self next];
    }];
}

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard alarmToAnotherPillSegueIdentifier]
                              sender:self];
}

#pragma mark - Actions

- (IBAction)setAlarmNow:(id)sender {
    UINavigationController* nav
        = (UINavigationController*)[HEMMainStoryboard instantiateAlarmNavController];
    if ([[nav topViewController] isKindOfClass:[HEMAlarmViewController class]]) {
        SENAlarm* alarm = [SENAlarm createDefaultAlarm];
        
        HEMAlarmViewController* alarmVC = (HEMAlarmViewController*)[nav topViewController];
        [alarmVC setAlarm:alarm];
        [alarmVC setDelegate:self];
    }
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)setAlarmLater:(id)sender {
    [self next];
}

#pragma mark - HEMAlarmControllerDelegate

- (void)didCancelAlarmFrom:(HEMAlarmViewController *)alarmVC {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didSaveAlarm:(__unused SENAlarm *)alarm from:(HEMAlarmViewController *)alarmVC {
    [self dismissAlarmVC:alarmVC];
}

@end
