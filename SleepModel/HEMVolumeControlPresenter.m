//
//  HEMVolumeControlPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSenseMetadata.h>

#import "HEMVolumeControlPresenter.h"
#import "HEMVoiceService.h"
#import "HEMStyle.h"
#import "HEMActionButton.h"
#import "HEMVolumeSlider.h"
#import "HEMScreenUtils.h"

@interface HEMVolumeControlPresenter() <HEMVolumeChangeDelegate>

@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, strong) SENSenseVoiceInfo* voiceInfo;

@property (nonatomic, weak) HEMVolumeSlider* volumeSlider;
@property (nonatomic, weak) UILabel* volumeLabel;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* descriptionLabel;
@property (nonatomic, weak) UIButton* cancelButton;
@property (nonatomic, weak) HEMActionButton* saveButton;

@end

@implementation HEMVolumeControlPresenter

- (instancetype)initWithVoiceInfo:(SENSenseVoiceInfo*)voiceInfo
                     voiceService:(HEMVoiceService*)voiceService {
    if (self = [super init]) {
        _voiceService = voiceService;
        _voiceInfo = voiceInfo;
    }
    return self;
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel
  descriptionTopConstraint:(NSLayoutConstraint*)descriptionTopConstraint {
    if (HEMIsIPhone4Family()) {
        [titleLabel setText:nil];
        [descriptionTopConstraint setConstant:0.0f];
        [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    } else {
        [titleLabel setText:NSLocalizedString(@"voice.settings.volume.control.title", nil)];
        [titleLabel setFont:[UIFont h4]];
        [titleLabel setTextColor:[UIColor grey6]];
    }
    
    [descriptionLabel setText:NSLocalizedString(@"voice.settings.volume.control.description", nil)];
    [descriptionLabel setFont:[UIFont body]];
    [descriptionLabel setTextColor:[UIColor grey5]];
    
    [self setTitleLabel:titleLabel];
    [self setDescriptionLabel:descriptionLabel];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    if (HEMIsIPhone4Family()) {
        [navItem setTitle:NSLocalizedString(@"voice.settings.volume.control.title", nil)];
    }
}

- (void)bindWithVolumeLabel:(UILabel*)volumeLabel volumeSlider:(HEMVolumeSlider*)volumeSlider {
    NSInteger volumeLevel = [[self voiceService] volumeLevelFrom:[self voiceInfo]];
    
    [volumeLabel setFont:[UIFont h1]];
    [volumeLabel setTextColor:[UIColor tintColor]];
    [volumeLabel setText:[NSString stringWithFormat:@"%ld", volumeLevel]];
    
    [volumeSlider setHighlightColor:[UIColor tintColor]];
    [volumeSlider setNormalColor:[UIColor grey3]];
    [volumeSlider setCurrentVolume:volumeLevel];
    [volumeSlider setChangeDelegate:self];
    [volumeSlider setMaxVolumeLevel:HEMVoiceServiceMaxVolumeLevel];
    
    [self setVolumeLabel:volumeLabel];
    [self setVolumeSlider:volumeSlider];
}

- (void)bindWithCancelButton:(UIButton*)cancelButton saveButton:(HEMActionButton*)saveButton {
    [[cancelButton titleLabel] setFont:[UIFont button]];
    [cancelButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [cancelButton setTitle:NSLocalizedString(@"actions.cancel", nil) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self setCancelButton:cancelButton];
    [self setSaveButton:saveButton];
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    if (![[self volumeSlider] isRendered]) {
        [[self volumeSlider] render];
    }
}

#pragma mark - Actions

- (void)cancel {
    [[self delegate] didSave:NO volumeFromPresenter:self];
}

#pragma mark - HEMVolumeChangeDelegate

- (void)didChangeVolumeTo:(NSInteger)volume fromSlider:(HEMVolumeSlider *)slider {
    DDLogVerbose(@"did change volume to %ld", volume);
    [[self volumeLabel] setText:[NSString stringWithFormat:@"%ld", volume]];
}

@end
