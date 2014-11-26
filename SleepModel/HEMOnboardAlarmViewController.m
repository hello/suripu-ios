//
//  HEMOnboardAlarmViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAlarm.h>

#import "UIView+HEMSnapshot.h"

#import "HEMOnboardAlarmViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMScrollableView.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMAlarmViewController.h"

@interface HEMOnboardAlarmViewController() <HEMAlarmControllerDelegate>

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

@end

@implementation HEMOnboardAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    
    [self setupContent];
    
    [HEMOnboardingUtils applyShadowToButtonContainer:[self buttonContainer]];
}

- (void)setupContent {
    [[self contentView] addTitle:NSLocalizedString(@"onboarding.alarm.title", nil)];
    [[self contentView] addImage:[HelloStyleKit smartAlarm]];

    NSString* desc = NSLocalizedString(@"onboarding.alarm.desc", nil);
    NSMutableAttributedString* attrDesc = [[NSMutableAttributedString alloc] initWithString:desc];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrDesc];
    
    [[self contentView] addDescription:attrDesc];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat opacity = [[self contentView] scrollRequired]?1.0f:0.0f;
    [[[self buttonContainer] layer] setShadowOpacity:opacity];
}

- (void)dismissAlarmVC:(HEMAlarmViewController*)alarmVC {
    UIImage* snapshot = [[[[UIApplication sharedApplication] delegate] window] snapshot];
    UIImageView* snapView = [[UIImageView alloc] initWithImage:snapshot];
    UIView* containingView = [[self navigationController] view];
    [snapView setFrame:[containingView bounds]];
    [containingView addSubview:snapView];

    [self dismissViewControllerAnimated:NO completion:^{
        [HEMOnboardingUtils finisOnboardinghWithMessageFrom:self];
    }];
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
    [HEMOnboardingUtils finisOnboardinghWithMessageFrom:self];
}

#pragma mark - HEMAlarmControllerDelegate

- (void)didCancelAlarmFrom:(HEMAlarmViewController *)alarmVC {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didSaveAlarm:(__unused SENAlarm *)alarm from:(HEMAlarmViewController *)alarmVC {
    [self dismissAlarmVC:alarmVC];
}

@end
