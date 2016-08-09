//
//  HEMOnboardAlarmViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSenseManager.h>

#import "UIView+HEMSnapshot.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMOnboardAlarmViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMAlarmViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingService.h"
#import "HEMEmbeddedVideoView.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActivityCoverView.h"

static CGFloat const HEMOnboardAlarmSavedDisplayDuration = 1.0f;
static CGFloat const HEMOnboardAlarmSavedAnimeDuration = 1.0f;
static CGFloat const HEMOnboardAlarmCompleteDuration = 2.0f;

@interface HEMOnboardAlarmViewController() <HEMAlarmControllerDelegate>

@property (weak, nonatomic) IBOutlet HEMEmbeddedVideoView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation HEMOnboardAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureVideoView];
    [self configureButton];
    [self doubleCheckResources];
    [self trackAnalyticsEvent:HEMAnalyticsEventFirstAlarm];
}

- (void)configureButton {
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [self enableBackButton:NO];
}

- (void)doubleCheckResources {
    HEMOnboardingService* onbService = [HEMOnboardingService sharedService];
    [onbService checkIfSenseDFUIsRequired];
    [onbService checkFeatures];
}

- (void)configureVideoView {
    UIImage* image = [UIImage imageNamed:@"smartAlarm"];
    NSString* videoPath = NSLocalizedString(@"video.url.onboarding.alarm", nil);
    [[self videoView] setFirstFrame:image videoPath:videoPath];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[self videoView] isReady]) {
        [[self videoView] setReady:YES];
    } else {
        [[self videoView] playVideoWhenReady];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self videoView] pause];
}

- (BOOL)willBeDoneWithOnboarding {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    return ![service isDFURequiredForSense] && ![service isVoiceAvailable];
}

#pragma mark - Actions

- (IBAction)setAlarmNow:(id)sender {
    UINavigationController* nav
        = (UINavigationController*)[HEMMainStoryboard instantiateAlarmNavController];
    if ([[nav topViewController] isKindOfClass:[HEMAlarmViewController class]]) {
        SENAlarm* alarm = [SENAlarm createDefaultAlarm];
        
        NSString* successText = nil;
        CGFloat successDuration = 0.0f;
        if ([self willBeDoneWithOnboarding]) {
            successText = NSLocalizedString(@"onboarding.end-message.well-done", nil);
            successDuration = HEMOnboardAlarmCompleteDuration;
        }
        HEMAlarmViewController* alarmVC = (HEMAlarmViewController*)[nav topViewController];
        [alarmVC setAlarm:alarm];
        [alarmVC setSuccessText:successText];
        [alarmVC setSuccessDuration:successDuration];
        [alarmVC setDelegate:self];
    }
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)setAlarmLater:(id)sender {
    [self next:NO];
}

#pragma mark - HEMAlarmControllerDelegate

- (void)didCancelAlarmFrom:(HEMAlarmViewController *)alarmVC {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didSaveAlarm:(__unused SENAlarm *)alarm from:(HEMAlarmViewController *)alarmVC {
    UIView* snapshot = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    UIView* parentView = [[self navigationController] view];
    [parentView addSubview:snapshot];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self next:YES];
        if (![self willBeDoneWithOnboarding]) {
            [UIView animateWithDuration:HEMOnboardAlarmSavedAnimeDuration
                                  delay:HEMOnboardAlarmSavedDisplayDuration
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [snapshot setAlpha:0.0f];
                             }
                             completion:^(BOOL finished) {
                                 [snapshot removeFromSuperview];
                             }];
        }
    }];
}

#pragma mark - Next

- (void)next:(BOOL)savedAlarm {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    if ([service isDFURequiredForSense]) {
        UIViewController* controller = [HEMOnboardingStoryboard instantiateSenseDFUViewController];
        [[self navigationController] setViewControllers:@[controller] animated:YES];
    } else if ([service isVoiceAvailable]) {
        UIViewController* controller = [HEMOnboardingStoryboard instantiateVoiceTutorialViewController];
        [[self navigationController] setViewControllers:@[controller] animated:YES];
    } else if (savedAlarm) {
        [self completeOnboardingWithoutMessage];
    } else {
        [self completeOnboarding];
    }
}

@end
