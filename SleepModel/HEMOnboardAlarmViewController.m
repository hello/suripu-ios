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

@interface HEMOnboardAlarmViewController() <HEMAlarmControllerDelegate>

@property (weak, nonatomic) IBOutlet HEMEmbeddedVideoView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation HEMOnboardAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureVideoView];
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [self enableBackButton:NO];
    
    [[HEMOnboardingService sharedService] checkIfSenseDFUIsRequired]; // in case RC was not shown
    
    [self trackAnalyticsEvent:HEMAnalyticsEventFirstAlarm];
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
    UINavigationController* nav = [self navigationController];
    
    UIImage* snapshot = [[alarmVC view] snapshot];
    UIImageView* overlay = [[UIImageView alloc] initWithFrame:[[nav view] bounds]];
    [overlay setImage:snapshot];

    [[nav view] addSubview:overlay];
    [self dismissViewControllerAnimated:NO completion:^{
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        if (![service isDFURequiredForSense]) {
            [self next];
        } else {
            HEMActivityCoverView* coverView = [HEMActivityCoverView new];
            NSString* savedText = NSLocalizedString(@"actions.alarm-saved", nil);
            [coverView showInView:overlay withText:savedText successMark:YES completion:^{
                [self next];
                [UIView animateWithDuration:HEMOnboardAlarmSavedAnimeDuration
                                      delay:HEMOnboardAlarmSavedDisplayDuration
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     [overlay setAlpha:0.0f];
                                 }
                                 completion:^(BOOL finished) {
                                     [overlay removeFromSuperview];
                                 }];
            }];
        }
    }];
}

#pragma mark - Next

- (void)next {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    if (![service isDFURequiredForSense]) {
        [self completeOnboarding];
    } else {
        UIViewController* controller = [HEMOnboardingStoryboard instantiateSenseDFUViewController];
        [[self navigationController] setViewControllers:@[controller] animated:YES];
    }
}

@end
