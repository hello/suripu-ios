//
//  HEMVoiceTutorialViewController.m
//  Sense
//
//  Created by Jimmy Lu on 7/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceTutorialViewController.h"
#import "HEMActionButton.h"
#import "HEMVoiceTutorialPresenter.h"
#import "HEMVoiceService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingService.h"

@interface HEMVoiceTutorialViewController () <HEMVoiceTutorialDelegate>

@property (weak, nonatomic) IBOutlet UIView *voiceContentContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceContentCenterConstraint;
@property (weak, nonatomic) IBOutlet UILabel *tryNowLabel;
@property (weak, nonatomic) IBOutlet UIView *speechContainer;
@property (weak, nonatomic) IBOutlet UILabel *speechCommandLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speechCommandBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *speechErrorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speechErrorBottomConstraint;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *laterButton;
@property (weak, nonatomic) IBOutlet UIImageView *tableImageView;
@property (weak, nonatomic) IBOutlet UIImageView *senseImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *laterButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *senseHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *senseWidthConstraint;
@property (strong, nonatomic) HEMVoiceService* voiceService;

@end

@implementation HEMVoiceTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventVoiceTutorial];
}

- (void)trackAnalyticsEvent:(NSString *)event {
    if ([self flow]) {
        [SENAnalytics track:event];
    } else {
        [SENAnalytics track:event properties:nil onboarding:YES];
    }
}

- (void)configurePresenter {
    HEMVoiceService* voiceService = [HEMVoiceService new];
    HEMVoiceTutorialPresenter* presenter =
        [[HEMVoiceTutorialPresenter alloc] initWithVoiceService:voiceService];
    
    [presenter bindWithTryNowLabel:[self tryNowLabel]];
    [presenter bindWithVoiceContentContainer:[self voiceContentContainer]
                        withCenterConstraint:[self voiceContentCenterConstraint]];
    [presenter bindWithSpeechLabelContainer:[self speechContainer]
                               commandLabel:[self speechCommandLabel]
                    commandBottomConstraint:[self speechCommandBottomConstraint]
                                 errorLabel:[self speechErrorLabel]
                      errorBottomConstraint:[self speechErrorBottomConstraint]];
    [presenter bindWithNavigationItem:[self navigationItem]];
    [presenter bindWithContinueButton:[self continueButton]];
    [presenter bindWithLaterButton:[self laterButton]
              withBottomConstraint:[self laterButtonBottomConstraint]];
    [presenter bindWithTableImageView:[self tableImageView]
                 withBottomConstraint:[self tableBottomConstraint]];
    [presenter bindWithSenseImageView:[self senseImageView]
                  withWidthConstraint:[self senseWidthConstraint]
                  andHeightConstraint:[self senseHeightConstraint]];
    [presenter bindWithTitleLabel:[self titleLabel]
                 descriptionLabel:[self descriptionLabel]];
    [presenter setOnboarding:![self flow]];
    [presenter setDelegate:self];
    
    [self addPresenter:presenter];
    [self setVoiceService:voiceService];
}

#pragma mark - Voice Tutorial Delegate

- (void)didFinishTutorialFrom:(__unused HEMVoiceTutorialPresenter *)presenter {
    if (![self continueWithFlowBySkipping:NO]) {
        UIViewController* lastVC = [HEMOnboardingStoryboard instantiateOnboardingCompleteViewController];
        [[self navigationController] setViewControllers:@[lastVC] animated:YES];
    }
}

- (void)showController:(UIViewController *)controller
         fromPresenter:(HEMVoiceTutorialPresenter *)presenter {
    [self presentViewController:controller animated:YES completion:nil];
}

@end
