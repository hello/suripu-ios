//
//  HEMSenseDFUViewController.m
//  Sense
//
//  Created by Jimmy Lu on 7/19/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSenseDFUViewController.h"
#import "HEMActionButton.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSenseDFUPresenter.h"
#import "HEMOnboardingService.h"

@interface HEMSenseDFUViewController () <HEMSenseDFUDelegate, HEMPresenterErrorDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *illustrationView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation HEMSenseDFUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    HEMOnboardingService* onbService = [HEMOnboardingService sharedService];
    HEMSenseDFUPresenter* presenter = [[HEMSenseDFUPresenter alloc] initWithOnboardingService:onbService];
    [presenter bindWithUpdateButton:[self continueButton]];
    [presenter bindWithActivityIndicator:[self activityIndicator]
                             statusLabel:[self statusLabel]];
    [presenter setErrorDelegate:self];
    [presenter setDfuDelegate:self];
    [self addPresenter:presenter];
}

#pragma mark - DFU Delegate

- (void)senseUpdateLaterFrom:(HEMSenseDFUPresenter *)presenter {
    // TODO: go to voice tutorials
    [self completeOnboarding];
}

- (void)senseUpdateCompletedFrom:(HEMSenseDFUPresenter *)presenter {
    // TODO: go to voice tutorials
    [self completeOnboarding];
}

#pragma mark - Error Delegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    [self showMessageDialog:message
                      title:title
                      image:nil
               withHelpPage:nil];
}

@end
