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

@interface HEMVoiceTutorialViewController () <HEMVoiceTutorialDelegate>

@property (weak, nonatomic) IBOutlet UIView *speechContainer;
@property (weak, nonatomic) IBOutlet UILabel *speechTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *speechCommandLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speechCommandBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *speechErrorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speechErrorBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speechContainerBottomConstraint;
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
}

- (void)configurePresenter {
    HEMVoiceService* voiceService = [HEMVoiceService new];
    HEMVoiceTutorialPresenter* presenter =
        [[HEMVoiceTutorialPresenter alloc] initWithVoiceService:voiceService];
    [presenter bindWithSpeechContainer:[self speechContainer]
             containerBottomConstraint:[self speechContainerBottomConstraint]
                            titleLabel:[self speechTitleLabel]
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
    [presenter setDelegate:self];
    [self addPresenter:presenter];
    [self setVoiceService:voiceService];
}

#pragma mark - Voice Tutorial Delegate

- (void)didFinishTutorialFrom:(HEMVoiceTutorialPresenter *)presenter {
    [self completeOnboarding];
}

- (void)showController:(UIViewController *)controller fromPresenter:(HEMVoiceTutorialPresenter *)presenter {
    [self presentViewController:controller animated:YES completion:nil];
}

@end
