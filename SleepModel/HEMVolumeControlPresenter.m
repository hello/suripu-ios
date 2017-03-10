//
//  HEMVolumeControlPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENSenseVoiceSettings.h>

#import "Sense-Swift.h"

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
@property (nonatomic, weak) UINavigationBar* navBar;
@property (nonatomic, strong) SENSenseVoiceSettings* cachedSettings;

@end

@implementation HEMVolumeControlPresenter

- (instancetype)initWithVoiceSettings:(SENSenseVoiceSettings*)voiceSettings
                              senseId:(NSString*)senseId
                         voiceService:(HEMVoiceService*)voiceService {
    if (self = [super init]) {
        _voiceService = voiceService;
        _voiceSettings = voiceSettings;
        _senseId = senseId;
        _cachedSettings = [SENSenseVoiceSettings new];
        [_cachedSettings setVolume:[voiceSettings volume]];
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
    NSInteger volumeLevel = [[self voiceService] volumeLevelFrom:[self cachedSettings]];

    [volumeLabel setText:[NSString stringWithFormat:@"%ld", volumeLevel]];
    
    [volumeSlider setCurrentVolume:volumeLevel];
    [volumeSlider setChangeDelegate:self];
    [volumeSlider setMaxVolumeLevel:HEMVoiceServiceMaxVolumeLevel];
    [volumeSlider setBackgroundColor:[UIColor clearColor]];
    
    [self setVolumeLabel:volumeLabel];
    [self setVolumeSlider:volumeSlider];
}

- (void)bindWithCancelButton:(UIButton*)cancelButton saveButton:(HEMActionButton*)saveButton {
    [cancelButton setTitle:NSLocalizedString(@"actions.cancel", nil) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    
    [self setCancelButton:cancelButton];
    [self setSaveButton:saveButton];
}

- (void)bindWithNavigationBar:(UINavigationBar*)navBar {
    [self setNavBar:navBar];
}

#pragma mark - Presenter events

- (void)willAppear {
    [super willAppear];
    [self applyStyle];
}

- (void)didAppear {
    [super didAppear];
    if (![[self volumeSlider] isRendered]) {
        [[self volumeSlider] render];
    }
}

- (void)didChangeTheme:(Theme *)theme {
    [super didChangeTheme:theme];
    [self applyStyle];
}

#pragma mark - Styling

- (void)applyStyle {
    static NSString* barTintColorPropName = @"sense.volume.bar.tint.color";
    static NSString* barColorPropName = @"sense.volume.bar.color";
    static NSString* volumeLabelFontPropName = @"sense.volume.number.font";
    UIColor* titleColor = [SenseStyle colorWithGroup:GroupVolumeControl property:ThemePropertyTextColor];
    UIFont* titleFont = [SenseStyle fontWithGroup:GroupVolumeControl property:ThemePropertyTextFont];
    UIColor* detailColor = [SenseStyle colorWithGroup:GroupVolumeControl property:ThemePropertyDetailColor];
    UIFont* detailFont = [SenseStyle fontWithGroup:GroupVolumeControl property:ThemePropertyDetailFont];
    UIColor* saveTextColor = [SenseStyle colorWithGroup:GroupVolumeControl property:ThemePropertyPrimaryButtonTextColor];
    UIColor* cancelTextColor = [SenseStyle colorWithGroup:GroupVolumeControl property:ThemePropertySecondaryButtonTextColor];
    UIColor* navBarColor = [SenseStyle colorWithGroup:GroupVolumeControl property:ThemePropertyNavigationBarTintColor];
    UIColor* volumeBarTintColor = [SenseStyle colorWithGroup:GroupVolumeControl propertyName:barTintColorPropName];
    UIColor* volumeBarColor = [SenseStyle colorWithGroup:GroupVolumeControl propertyName:barColorPropName];
    UIFont* volumeLabelFont = [SenseStyle fontWithGroup:GroupVolumeControl propertyName:volumeLabelFontPropName];
    [[self titleLabel] setTextColor:titleColor];
    [[self titleLabel] setFont:titleFont];
    [[self descriptionLabel] setTextColor:detailColor];
    [[self descriptionLabel] setFont:detailFont];
    [[self saveButton] setTitleColor:saveTextColor forState:UIControlStateNormal];
    [[self cancelButton] setTitleColor:cancelTextColor forState:UIControlStateNormal];
    [[self navBar] setBarTintColor:navBarColor];
    [[self volumeSlider] setHighlightColor:volumeBarTintColor];
    [[self volumeSlider] setNormalColor:volumeBarColor];
    [[self volumeLabel] setTextColor:volumeBarTintColor];
    [[self volumeLabel] setFont:volumeLabelFont];
}

#pragma mark - Actions

- (void)cancel {
    [[self delegate] dismissControlFrom:self];
}

- (void)save {
    __weak typeof(self) weakSelf = self;
    
    NSString* activityText = NSLocalizedString(@"voice.settings.update.status", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    [activityView showInView:[self activityContainer] withText:activityText activity:YES completion:^{
        [[self voiceService] updateVoiceSettings:[self cachedSettings]
                                      forSenseId:[self senseId]
                                      completion:^(SENSenseVoiceSettings* updated) {
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
                                              [[strongSelf voiceSettings] setVolume:[[strongSelf cachedSettings] volume]];
                                              NSString* successText = NSLocalizedString(@"status.success", nil);
                                              UIImage* check = [UIImage imageNamed:@"check"];
                                              [[activityView indicator] setHidden:YES];
                                              [activityView updateText:successText successIcon:check hideActivity:YES completion:^(BOOL finished) {
                                                  [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                                                      int64_t delayInSecs = (int64_t)(kHEMVolumeSavedMessageDuration * NSEC_PER_SEC);
                                                      dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
                                                      dispatch_after(delay, dispatch_get_main_queue(), ^{
                                                          __weak typeof(weakSelf) strongSelf = weakSelf;
                                                          [[strongSelf delegate] dismissControlFrom:strongSelf];
                                                          [[strongSelf updateDelegate] updatedVolumeFromPresenter:strongSelf];
                                                      });
                                                  }];
                                              }];
                                          }
                                      }];
    }];
}

#pragma mark - HEMVolumeChangeDelegate

- (void)didChangeVolumeTo:(NSInteger)volume fromSlider:(HEMVolumeSlider *)slider {
    NSInteger percentage = [[self voiceService] volumePercentageFromLevel:volume];
    DDLogVerbose(@"did change volume to %ld, percentage %ld", volume, percentage);
    [[self volumeLabel] setText:[NSString stringWithFormat:@"%ld", volume]];
    [[self cachedSettings] setVolume:@(percentage)];
}

@end
