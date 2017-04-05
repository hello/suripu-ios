//
//  HEMVoiceSettingsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENSenseVoiceSettings.h>

#import "Sense-Swift.h"

#import "NSString+HEMUtils.h"

#import "HEMVoiceSettingsPresenter.h"
#import "HEMVoiceService.h"
#import "HEMDeviceService.h"
#import "HEMSettingsStoryboard.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMActivityCoverView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAlertViewController.h"
#import "HEMBasicTableViewCell.h"
#import "HEMVolumeControlPresenter.h"

typedef NS_ENUM(NSUInteger, HEMVoiceSettingsRow){
    HEMVoiceSettingsRowVolume = 0,
    HEMVoiceSettingsRowMute,
    HEMVoiceSettingsRowPrimaryUser,
    HEMVoiceSettingsRowCount
};

static CGFloat const kHEMVoiceSettingsCellHeight = 56.0f;
static CGFloat const kHEMVoiceSettingsCellTextMargin = 24.0f;
static CGFloat const kHEMVoiceFootNoteHorzMargins = 24.0f;
static CGFloat const kHEMVoiceFootNoteVertMargins = 12.0f;

@interface HEMVoiceSettingsPresenter() <
    UITableViewDelegate,
    UITableViewDataSource,
    HEMVolumeControlUpdateDelegate
>

@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) UIView* activityContainerView;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) NSError* dataError;
@property (nonatomic, strong) SENSenseVoiceSettings* voiceSettings;
@property (nonatomic, assign, getter=isUpdating) BOOL updating;

@end

@implementation HEMVoiceSettingsPresenter

- (instancetype)initWithVoiceService:(HEMVoiceService*)voiceService
                       deviceService:(HEMDeviceService*)deviceService {
    if (self = [super init]) {
        _voiceService = voiceService;
        _deviceService = deviceService;
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView {
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    HEMSettingsHeaderFooterView* footerView = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    NSString* footNote = NSLocalizedString(@"voice.settings.primary-user.foot.note", nil);
    NSDictionary* attrs = @{NSFontAttributeName : [UIFont h7Bold],
                            NSForegroundColorAttributeName : [UIColor grey3]};
    NSAttributedString* attributedFootNote = [[NSAttributedString alloc] initWithString:footNote attributes:attrs];
    [footerView setAttributedTitle:attributedFootNote];
    [footerView setTitleInsets:UIEdgeInsetsMake(kHEMVoiceFootNoteVertMargins,
                                                kHEMVoiceFootNoteHorzMargins,
                                                kHEMVoiceFootNoteVertMargins,
                                                kHEMVoiceFootNoteHorzMargins)];
    [footerView setHidden:YES];
    [footerView setAdjustBasedOnTitle:YES];
    [tableView setTableFooterView:footerView];
    [tableView applyStyle];
    [self setTableView:tableView];
    [self updateTableHeaderView];
    [self listenForOutsideUpdates];
}

- (void)updateTableHeaderView {
    UIView* view = nil;
    if ([[self voiceService] isFirmwareUpdateRequiredFromError:[self dataError]]) {
        CGFloat width = CGRectGetWidth([[self tableView] bounds]);
        view = [[StatusMesssageView alloc] initWithWidth:width
                                                   image:[UIImage imageNamed:@"senseUpdate"]
                                                   title:NSLocalizedString(@"voice.settings.fw.update.title", nil)
                                                 message:NSLocalizedString(@"voice.settings.fw.update.message", nil)];
    } else {
        view = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    }
    [[self tableView] setTableHeaderView:view];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    [navItem setTitle:NSLocalizedString(@"settings.voice", nil)];
}

- (void)bindWithActivityContainer:(UIView*)activityContainer {
    [self setActivityContainerView:activityContainer];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicatorView {
    [activityIndicatorView start];
    [activityIndicatorView setHidden:NO];
    [self setActivityIndicatorView:activityIndicatorView];
}

#pragma mark - Presenter events

- (void)didChangeTheme:(Theme *)theme auto:(BOOL)automatically {
    [super didChangeTheme:theme auto:automatically];
    [[self tableView] applyStyle];
    [[self tableView] reloadData];
}

- (void)didRelayout {
    [super didRelayout];
    
    UIView* footer = [[self tableView] tableFooterView];
    [footer sizeToFit];
    [[self tableView] setTableFooterView:footer];
}

- (void)didAppear {
    [super didAppear];
    [self updateUI];
}

#pragma mark - Notifications

- (void)listenForOutsideUpdates {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(voiceSettingsUpdated:)
                   name:HEMVoiceNotificationSettingsUpdated
                 object:nil];
}

- (void)voiceSettingsUpdated:(NSNotification*)note {
    if (![self isUpdating]) { // some outside action, so update if needed
        NSDictionary* info = [note userInfo];
        if (info) {
            SENSenseVoiceSettings* updatedSettings = [note userInfo][HEMVoiceNotificationInfoSettings];
            if (updatedSettings) {
                [self setVoiceSettings:updatedSettings];
            }
        }
        [[self tableView] reloadData];
    }
}

#pragma mark - Data

- (void)updateUI {
    __weak typeof(self) weakSelf = self;
    void(^reload)(NSError* error) = ^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setDataError:error];
        [[[strongSelf tableView] tableFooterView] setHidden:error != nil];
        [strongSelf updateTableHeaderView];
        [[strongSelf tableView] reloadData];
        [[strongSelf activityIndicatorView] stop];
        [[strongSelf activityIndicatorView] setHidden:YES];
    };
    
    void(^loadVoiceSettings)(SENSenseMetadata* senseMetadata) = ^(SENSenseMetadata* senseMetadata) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString* senseId = [senseMetadata uniqueId];
        [[strongSelf voiceService] getVoiceSettingsForSenseId:senseId completion:^(id response, NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setVoiceSettings:response];
            reload(error);
        }];
    };
    
    if ([[[self deviceService] devices] senseMetadata]) {
        loadVoiceSettings([[[self deviceService] devices] senseMetadata]);
    } else {
        [[self deviceService] refreshMetadata:^(SENPairedDevices * devices, NSError * error) {
            if (error) {
                reload(error);
            } else {
                loadVoiceSettings([devices senseMetadata]);
            }
        }];
    }
}

- (NSString*)dataErrorMessage {
    NSString* errorMessage = [[self dataError] localizedDescription];
    if ([errorMessage length] == 0) {
        errorMessage = NSLocalizedString(@"voice.settings.error.message", nil);
    }
    return errorMessage;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if ([[self voiceService] isFirmwareUpdateRequiredFromError:[self dataError]]) {
        rows = 0;
    } else if ([self dataError]) {
        rows = 1;
    } else if ([self voiceSettings] == nil) {
        rows = 0;
    } else {
        rows = HEMVoiceSettingsRowCount;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    CGFloat height = kHEMVoiceSettingsCellHeight;
    if (row == 0 && [self dataError]) {
        NSString* message = [self dataErrorMessage];
        CGFloat margins = kHEMVoiceSettingsCellTextMargin * 2.0f;
        CGFloat textWidth = CGRectGetWidth([tableView bounds]) - margins;
        height = [message heightBoundedByWidth:textWidth usingFont:[UIFont body]];
        height += margins;
    }
    return height;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    if ([self dataError]) {
        reuseId = [HEMSettingsStoryboard errorReuseIdentifier];
    } else if ([indexPath row] != HEMVoiceSettingsRowMute) {
        reuseId = [HEMSettingsStoryboard voiceSettingCellReuseIdentifier];
    } else {
        reuseId = [HEMSettingsStoryboard switchReuseIdentifier];
    }
    return [tableView dequeueReusableCellWithIdentifier:reuseId
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self dataError] && [indexPath row] == 0) {
        [[cell textLabel] setText:[self dataErrorMessage]];
        [[cell textLabel] setNumberOfLines:0];
        [cell applyStyle];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell sizeToFit];
    } else if (![self dataError]) {
        HEMBasicTableViewCell* basicCell = (id) cell;
        
        BOOL showCustomAccessory = YES;
        BOOL highlightDetail = NO;
        NSString* title = nil;
        NSString* detail = nil;
        UITableViewCellSelectionStyle selectionStyle = UITableViewCellSelectionStyleGray;
        
        switch ([indexPath row]) {
            default:
            case HEMVoiceSettingsRowVolume: {
                title = NSLocalizedString(@"voice.settings.volume", nil);
                NSInteger volumeLevel = [[self voiceService] volumeLevelFrom:[self voiceSettings]];
                detail = [NSString stringWithFormat:@"%ld", volumeLevel];
                break;
            }
            case HEMVoiceSettingsRowMute: {
                title = NSLocalizedString(@"voice.settings.mute", nil);
                selectionStyle = UITableViewCellSelectionStyleNone;
                
                UISwitch* control = (UISwitch*) [basicCell customAccessoryView];
                [control setOnTintColor:[UIColor tintColor]];
                [control setOn:[[self voiceSettings] isMuted]];
                [control addTarget:self
                            action:@selector(toggleMute:)
                  forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case HEMVoiceSettingsRowPrimaryUser: {
                title = NSLocalizedString(@"voice.settings.primary-user", nil);

                if ([[self voiceSettings] isPrimaryUser]) {
                    detail = NSLocalizedString(@"voice.settings.primary-user.you", nil);
                    selectionStyle = UITableViewCellSelectionStyleNone;
                    showCustomAccessory = NO;
                } else {
                    detail = NSLocalizedString(@"voice.settings.primary-user.change", nil);
                    highlightDetail = YES;
                }
                break;
            }
        }
        
        [basicCell applyStyle];
        [[basicCell customTitleLabel] setText:title];
        [[basicCell customDetailLabel] setText:detail];
        [basicCell detail:highlightDetail];
        [basicCell showCustomAccessoryView:showCustomAccessory];
        [basicCell setSelectionStyle:selectionStyle];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![self dataError]) {
        switch ([indexPath row]) {
            case HEMVoiceSettingsRowVolume:
                return [self changeVolume];
            case HEMVoiceSettingsRowPrimaryUser:
                if (![[self voiceSettings] isPrimaryUser]) {
                    return [self showPrimaryUserConfirmation];
                } else {
                    return;
                }
            default:
                return;
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Updates

- (void)update:(SENSenseVoiceSettings*)info
messageIfError:(NSString*)errorMessage
    completion:(void(^)(BOOL updated))completion {
    __weak typeof(self) weakSelf = self;
    
    SENSenseMetadata* metadata = [[[self deviceService] devices] senseMetadata];

    [self setUpdating:YES];
    
    NSString* activityText = NSLocalizedString(@"voice.settings.update.status", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    [activityView showInView:[self activityContainerView] withText:activityText activity:YES completion:^{
        [[self voiceService] updateVoiceSettings:info
                                      forSenseId:[metadata uniqueId]
                                      completion:^(SENSenseVoiceSettings* updated) {
                                          __strong typeof(weakSelf) strongSelf = weakSelf;
                                          [strongSelf setUpdating:NO];
                                          
                                          if (completion) {
                                              completion (updated != nil);
                                          }
                                      
                                          if (!updated) {
                                              [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                                                  [strongSelf showUpdateError:errorMessage];
                                              }];
                                          } else {
                                              [strongSelf setVoiceSettings:updated];
                                              [[strongSelf tableView] reloadData];
                                              NSString* successText = NSLocalizedString(@"status.success", nil);
                                              [activityView dismissWithResultText:successText showSuccessMark:YES remove:YES completion:nil];
                                          }
                                      }];
    }];
}

#pragma mark - Mute

- (void)toggleMute:(UISwitch*)control {
    NSString* errorMessage = NSLocalizedString(@"voice.settings.update.error.mute-not-changed", nil);
    BOOL mute = [control isOn];
    
    SENSenseVoiceSettings* muteSettings = [SENSenseVoiceSettings new];
    [muteSettings setMuted:@(mute)];
    
    __block SENSenseVoiceSettings* voiceSettings = [self voiceSettings];

    [self update:muteSettings messageIfError:errorMessage completion:^(BOOL updated) {
        if (!updated) {
            [control setOn:!mute];
        } else {
            [voiceSettings setMuted:@(!mute)];
        }
    }];
}

#pragma mark - Primary User

- (void)showPrimaryUserConfirmation {
    NSString* title = NSLocalizedString(@"voice.settings.primary-user.confirm.title", nil);
    NSString* message = NSLocalizedString(@"voice.settings.primary-user.confirm.message", nil);
    
    __weak typeof(self) weakSelf = self;
    HEMAlertViewController *dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"voice.settings.primary-user.confirm.ok", nil)
                           style:HEMAlertViewButtonStyleRoundRect
                          action:^{
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              [strongSelf setAsPrimary];
                          }];
    
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.cancel", nil)
                           style:HEMAlertViewButtonStyleBlueText
                          action:nil];
    
    [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
}

- (void)setAsPrimary {
    NSString* errorMessage = NSLocalizedString(@"voice.settings.update.error.primary-not-set", nil);
    
    SENSenseVoiceSettings* primarySettings = [SENSenseVoiceSettings new];
    [primarySettings setPrimaryUser:@YES];
    
    __block SENSenseVoiceSettings* voiceSettings = [self voiceSettings];

    [self update:primarySettings messageIfError:errorMessage completion:^(BOOL updated) {
        if (updated) {
            [voiceSettings setPrimaryUser:@YES];
        }
    }];
}

#pragma mark - Volume

- (void)changeVolume {
    SENSenseMetadata* metadata = [[[self deviceService] devices] senseMetadata];
    HEMVolumeControlPresenter* presenter =
    [[HEMVolumeControlPresenter alloc] initWithVoiceSettings:[self voiceSettings]
                                                     senseId:[metadata uniqueId]
                                                voiceService:[self voiceService]];
    [presenter setUpdateDelegate:self];
    [[self delegate] showVolumeControlWithPresenter:presenter
                                      fromPresenter:self];
}

#pragma mark - HEMVolumeControlUpdateDelegate

- (void)updatedVolumeFromPresenter:(HEMVolumeControlPresenter *)presenter {
    [self updateUI];
}

#pragma mark - Error

- (void)showUpdateError:(NSString*)message {
    NSString* title = NSLocalizedString(@"voice.settings.update.error.title", nil);
    [[self errorDelegate] showErrorWithTitle:title
                                  andMessage:message
                                withHelpPage:nil
                               fromPresenter:self];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
