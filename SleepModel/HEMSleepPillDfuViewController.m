//
//  HEMSleepPillDfuViewController.m
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSleepPillDfuViewController.h"
#import "HEMPillDfuPresenter.h"
#import "HEMDeviceService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMMainStoryboard.h"
#import "HEMNoBLEViewController.h"
#import "HEMSleepPillFinderViewController.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"

@class SENSleepPill;

@interface HEMSleepPillDfuViewController () <
    HEMPresenterErrorDelegate,
    HEMPillDfuDelegate,
    HEMNoBLEDelegate
>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *illustrationImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@end

@implementation HEMSleepPillDfuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    if (![self deviceService]) {
        [self setDeviceService:[HEMDeviceService new]];
    }
    
    HEMPillDfuPresenter* dfuPresenter =
        [[HEMPillDfuPresenter alloc] initWithDeviceService:[self deviceService]];
    [dfuPresenter setPillToDfu:[self sleepPillToDfu]];
    [dfuPresenter bindWithTitleLabel:[self titleLabel]
                    descriptionLabel:[self descriptionLabel]];
    [dfuPresenter bindWithActionButton:[self continueButton]];
    [dfuPresenter bindWithProgressView:[self progressView]
                           statusLabel:[self statusLabel]];
    [dfuPresenter setErrorDelegate:self];
    [dfuPresenter setDfuDelegate:self];
    [dfuPresenter bindWithCancelButton:[self cancelButton]];
    [dfuPresenter bindWithHelpButton:[self helpButton]];
    [dfuPresenter bindWithIllustrationView:[self illustrationImageView]];
    
    [self addPresenter:dfuPresenter];
}

- (void)next {
    HEMSleepPillFinderViewController* pillFinderVC =
        [HEMMainStoryboard instantiatePillFinderViewController];
    [pillFinderVC setDeviceService:[self deviceService]];
    [[self navigationController] setViewControllers:@[pillFinderVC] animated:YES];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    [self showMessageDialog:message
                      title:title
                      image:nil
               withHelpPage:helpPage];
}

#pragma mark - HEMPillDfuDelegate

- (void)bleRequiredToProceedFrom:(HEMPillDfuPresenter*)presenter {
    HEMNoBLEViewController* bleController = [HEMOnboardingStoryboard instantiateNoBleViewController];
    [bleController setDelegate:self];
    [[self navigationController] pushViewController:bleController animated:YES];
}

- (void)shouldStartScanningForPillFrom:(HEMPillDfuPresenter*)presenter {
    [self next];
}

- (UIView*)viewToAttachToWhenFinishedIn:(HEMPillDfuPresenter*)presenter {
    return [[self navigationController] view];
}

- (void)didCompleteDfuFrom:(HEMPillDfuPresenter*)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelDfuFrom:(HEMPillDfuPresenter*)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showHelpWithSlug:(NSString*)slug fromPresenter:(HEMPillDfuPresenter*)presenter {
    [SENAnalytics track:kHEMAnalyticsEventOnBHelp properties:nil];
    [HEMSupportUtil openHelpToPage:slug fromController:self];
}

#pragma mark - HEMNoBLEDelegate

- (void)bleDetectedFrom:(HEMNoBLEViewController *)controller {
    [self next];
}

@end
