//
//  HEMVolumeControlViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVolumeControlViewController.h"
#import "HEMVoiceService.h"
#import "HEMActionButton.h"
#import "HEMVolumeControlPresenter.h"
#import "HEMVolumeSlider.h"

@interface HEMVolumeControlViewController () <HEMVolumeControlDelegate, HEMPresenterErrorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet HEMVolumeSlider *volumeSlider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* descriptionTopConstraint;

@end

@implementation HEMVolumeControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    [[self presenter] bindWithCancelButton:[self cancelButton]
                                saveButton:[self saveButton]];
    [[self presenter] bindWithVolumeLabel:[self volumeLabel]
                             volumeSlider:[self volumeSlider]];
    [[self presenter] bindWithTitleLabel:[self titleLabel]
                 descriptionLabel:[self descriptionLabel]
         descriptionTopConstraint:[self descriptionTopConstraint]];
    [[self presenter] bindWithNavigationItem:[self navigationItem]];
    [[self presenter] bindWithActivityContainer:[self view]];
    [[self presenter] setDelegate:self];
    [[self presenter] setErrorDelegate:self];
    
    [self addPresenter:[self presenter]];
}

#pragma mark - HEMVolumeControlDelegate

- (void)dismissControlFrom:(HEMVolumeControlPresenter*)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    [self showMessageDialog:message title:title];
}

@end
