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

@interface HEMVolumeControlViewController () <HEMVolumeControlDelegate>

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
    if (![self voiceService]) {
        [self setVoiceService:[HEMVoiceService new]];
    }
    
    HEMVolumeControlPresenter* presenter =
        [[HEMVolumeControlPresenter alloc] initWithVoiceInfo:[self voiceInfo]
                                                voiceService:[self voiceService]];
    [presenter bindWithCancelButton:[self cancelButton] saveButton:[self saveButton]];
    [presenter bindWithVolumeLabel:[self volumeLabel] volumeSlider:[self volumeSlider]];
    [presenter bindWithTitleLabel:[self titleLabel]
                 descriptionLabel:[self descriptionLabel]
         descriptionTopConstraint:[self descriptionTopConstraint]];
    [presenter bindWithNavigationItem:[self navigationItem]];
    [presenter setDelegate:self];
    
    [self addPresenter:presenter];
}

#pragma mark - HEMVolumeControlDelegate

- (void)didSave:(BOOL)save volumeFromPresenter:(HEMVolumeControlPresenter *)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
