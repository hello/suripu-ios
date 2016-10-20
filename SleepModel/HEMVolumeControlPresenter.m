//
//  HEMVolumeControlPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENSenseVoiceSettings.h>

#import "HEMVolumeControlPresenter.h"
#import "HEMVoiceService.h"
#import "HEMStyle.h"
#import "HEMActionButton.h"
#import "HEMVolumeSlider.h"
#import "HEMScreenUtils.h"
#import "HEMActivityCoverView.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const kHEMVolumeSavedMessageDuration = 2.0f;

@interface HEMVolumeControlPresenter() <HEMVolumeChangeDelegate>

@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, strong) SENSenseVoiceSettings* voiceSettings;

@property (nonatomic, weak) HEMVolumeSlider* volumeSlider;
@property (nonatomic, weak) UILabel* volumeLabel;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* descriptionLabel;
@property (nonatomic, weak) UIButton* cancelButton;
@property (nonatomic, weak) HEMActionButton* saveButton;
@property (nonatomic, weak) UIView* activityContainer;
@property (nonatomic, copy) NSString* senseId;

@end

@implementation HEMVolumeControlPresenter

- (instancetype)initWithVoiceSettings:(SENSenseVoiceSettings*)voiceSettings
                              senseId:(NSString*)senseId
                         voiceService:(HEMVoiceService*)voiceService {
    if (self = [super init]) {
        _voiceService = voiceService;
        _voiceSettings = voiceSettings;
        _senseId = senseId;
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

- (void)bindWithActivityContainer:(UIView*)activityContainer {
    [self setActivityContainer:activityContainer];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    if (HEMIsIPhone4Family()) {
        [navItem setTitle:NSLocalizedString(@"voice.settings.volume.control.title", nil)];
    }
}

- (void)bindWithVolumeLabel:(UILabel*)volumeLabel volumeSlider:(HEMVolumeSlider*)volumeSlider {
    NSInteger volumeLevel = [[self voiceService] volumeLevelFrom:[self voiceSettings]];
    
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
    
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)save {
    __weak typeof(self) weakSelf = self;
    
    NSString* activityText = NSLocalizedString(@"voice.settings.update.status", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    [activityView showInView:[self activityContainer] withText:activityText activity:YES completion:^{
        [[self voiceService] updateVoiceSettings:[self voiceSettings]
                                      forSenseId:[self senseId]
                                      completion:^(BOOL updated) {
                                          __strong typeof(weakSelf) strongSelf = weakSelf;
                                          if (!updated) {
                                              [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                                                  NSString* title = NSLocalizedString(@"voice.settings.update.error.title", nil);
                                                  NSString* message = NSLocalizedString(@"voice.settings.update.error.volume-not-set", nil);
                                                  [[strongSelf errorDelegate] showErrorWithTitle:title
                                                                                      andMessage:message
                                                                                    withHelpPage:nil
                                                                                   fromPresenter:self];
                                              }];
                                          } else {
                                              NSString* successText = NSLocalizedString(@"status.success", nil);
                                              UIImage* check = [UIImage imageNamed:@"check"];
                                              [[activityView indicator] setHidden:YES];
                                              [activityView updateText:successText successIcon:check hideActivity:YES completion:^(BOOL finished) {
                                                  [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                                                      int64_t delayInSecs = (int64_t)(kHEMVolumeSavedMessageDuration * NSEC_PER_SEC);
                                                      dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
                                                      dispatch_after(delay, dispatch_get_main_queue(), ^{
                                                          __weak typeof(weakSelf) strongSelf = weakSelf;
                                                          [[strongSelf delegate] didSave:YES volumeFromPresenter:strongSelf];
                                                      });
                                                  }];
                                              }];
                                          }
                                      }];
    }];
}

#pragma mark - HEMVolumeChangeDelegate

- (void)didChangeVolumeTo:(NSInteger)volume fromSlider:(HEMVolumeSlider *)slider {
    DDLogVerbose(@"did change volume to %ld", volume);
    [[self volumeLabel] setText:[NSString stringWithFormat:@"%ld", volume]];
    [[self voiceSettings] setVolume:@([[self voiceService] volumePercentageFromLevel:volume])];
}

@end
