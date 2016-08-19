//
//  HEMResetSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMResetSenseViewController.h"
#import "HEMActionButton.h"
#import "HEMResetSensePresenter.h"
#import "HEMSupportUtil.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMResetSenseViewController () <HEMPresenterErrorDelegate, HEMResetPresenterDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *illustrationView;
@property (weak, nonatomic) IBOutlet UIButton *laterButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *resetButton;

@end

@implementation HEMResetSenseViewController

- (void)viewDidLoad {
    [self configurePresenter];
    [super viewDidLoad];
}

- (void)configurePresenter {
    if (![self presenter]) {
        [self setPresenter:[HEMResetSensePresenter new]];
    }
    [[self presenter] bindWithTitleLabel:[self titleLabel] descriptionLabel:[self descriptionLabel]];
    [[self presenter] bindWithLaterButton:[self laterButton]];
    [[self presenter] bindWithActivityContainerView:[[self navigationController] view]];
    [[self presenter] bindWithResetButton:[self resetButton]];
    [[self presenter] setDelegate:self];
    [[self presenter] setErrorDelegate:self];
    [self addPresenter:[self presenter]];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    if (helpPage) {
        [self showMessageDialog:message
                          title:title
                          image:nil
                   withHelpPage:helpPage];
    } else {
        [self showMessageDialog:message title:title];
    }
}

#pragma mark - HEMResetPresenterDelegate

- (void)didFinishWithReset:(BOOL)skipped fromPresenter:(HEMResetSensePresenter *)presenter {
    if (![self continueWithFlowBySkipping:skipped]) {
        [self performSegueWithIdentifier:[HEMOnboardingStoryboard doneSegueIdentifier]
                                  sender:self];
    }
}

- (void)showHelpWithPage:(NSString*)page fromPresenter:(HEMResetSensePresenter*)presenter {
    [HEMSupportUtil openHelpToPage:page fromController:self];
}

@end
