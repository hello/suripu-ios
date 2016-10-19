//
//  HEMVoiceSettingsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseMetadata.h>

#import "HEMVoiceSettingsPresenter.h"
#import "HEMVoiceService.h"
#import "HEMDeviceService.h"
#import "HEMMainStoryboard.h"
#import "HEMStyle.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMActivityCoverView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAlertViewController.h"
#import "HEMBasicTableViewCell.h"

typedef NS_ENUM(NSUInteger, HEMVoiceSettingsRow){
    HEMVoiceSettingsRowVolume = 0,
    HEMVoiceSettingsRowPrimaryUser,
    HEMVoiceSettingsRowCount
};

static CGFloat const kHEMVoiceFootNoteHorzMargins = 24.0f;
static CGFloat const kHEMVoiceFootNoteVertMargins = 12.0f;

@interface HEMVoiceSettingsPresenter() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) UIView* activityContainerView;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) NSError* dataError;

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
    [tableView setSeparatorColor:[UIColor separatorColor]];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    HEMSettingsHeaderFooterView* headerView = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];
    HEMSettingsHeaderFooterView* footerView = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES bottomBorder:NO];
    NSString* footNote = NSLocalizedString(@"voice.settings.primary-user.foot.note", nil);
    NSDictionary* attrs = @{NSFontAttributeName : [UIFont h7Bold],
                            NSForegroundColorAttributeName : [UIColor grey3]};
    NSAttributedString* attributedFootNote = [[NSAttributedString alloc] initWithString:footNote attributes:attrs];
    [footerView setAttributedTitle:attributedFootNote];
    [footerView setTitleInsets:UIEdgeInsetsMake(kHEMVoiceFootNoteVertMargins,
                                                kHEMVoiceFootNoteHorzMargins,
                                                kHEMVoiceFootNoteVertMargins,
                                                kHEMVoiceFootNoteHorzMargins)];
    [footerView setAdjustBasedOnTitle:YES];
    
    [tableView setTableHeaderView:headerView];
    [tableView setTableFooterView:footerView];
    [tableView setHidden:YES];
    [self setTableView:tableView];
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

#pragma mark - Data

- (void)updateUI {
    __weak typeof(self) weakSelf = self;
    void(^reload)(NSError* error) = ^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setDataError:error];
        [[[strongSelf tableView] tableFooterView] setHidden:error != nil];
        [[strongSelf tableView] setHidden:NO];
        [[strongSelf tableView] reloadData];
        [[strongSelf activityIndicatorView] stop];
        [[strongSelf activityIndicatorView] setHidden:YES];
    };
    
    if ([[[self deviceService] devices] senseMetadata]) {
        reload(nil);
    } else {
        [[self deviceService] refreshMetadata:^(SENPairedDevices * devices, NSError * error) {
            reload(error);
        }];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self dataError] ? 1 : HEMVoiceSettingsRowCount;
}   

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    if ([self dataError]) {
        reuseId = [HEMMainStoryboard errorReuseIdentifier];
    } else {
        reuseId = [HEMMainStoryboard settingsReuseIdentifier];
    }
    return [tableView dequeueReusableCellWithIdentifier:reuseId
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self dataError] && [indexPath row] == 0) {
        [[cell textLabel] setText:NSLocalizedString(@"voice.settings.error.message", nil)];
        [[cell textLabel] setFont:[UIFont errorStateDescriptionFont]];
        [[cell textLabel] setTextColor:[UIColor grey4]];
        [[cell textLabel] setNumberOfLines:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell sizeToFit];
    } else if (![self dataError]) {
        HEMBasicTableViewCell* basicCell = (id) cell;
        SENSenseMetadata* senseMetadata = [[[self deviceService] devices] senseMetadata];
        SENSenseVoiceInfo* voiceInfo = [senseMetadata voiceInfo];
        
        BOOL showCustomAccessory = YES;
        NSString* title = nil;
        NSString* detail = nil;
        UIColor* detailColor = [UIColor grey4];
        UITableViewCellSelectionStyle selectionStyle = UITableViewCellSelectionStyleGray;
        
        switch ([indexPath row]) {
            default:
            case HEMVoiceSettingsRowVolume: {
                title = NSLocalizedString(@"voice.settings.volume", nil);
                NSInteger volumeLevel = [[self voiceService] volumeLevelFrom:voiceInfo];
                detail = [NSString stringWithFormat:@"%ld", volumeLevel];
                break;
            }
            case HEMVoiceSettingsRowPrimaryUser: {
                title = NSLocalizedString(@"voice.settings.primary-user", nil);

                if ([voiceInfo isPrimaryUser]) {
                    detail = NSLocalizedString(@"voice.settings.primary-user.you", nil);
                    selectionStyle = UITableViewCellSelectionStyleNone;
                    showCustomAccessory = NO;
                } else {
                    detail = NSLocalizedString(@"voice.settings.primary-user.change", nil);
                    detailColor = [UIColor tintColor];
                }
                break;
            }
        }
        
        [[basicCell customTitleLabel] setText:title];
        [[basicCell customTitleLabel] setFont:[UIFont body]];
        [[basicCell customTitleLabel] setTextColor:[UIColor grey6]];
        [[basicCell customDetailLabel] setText:detail];
        [[basicCell customDetailLabel] setFont:[UIFont body]];
        [[basicCell customDetailLabel] setTextColor:detailColor];
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
                return [self showPrimaryUserConfirmation];
            default:
                return;
        }
    }
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
    SENSenseMetadata* metadata = [[[self deviceService] devices] senseMetadata];
    NSString* senseId = [metadata uniqueId];
    SENSenseVoiceInfo* voiceInfo = [metadata voiceInfo];
    
    [voiceInfo setPrimaryUser:YES];
    
    NSString* activityText = NSLocalizedString(@"voice.settings.update.status", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    __weak typeof(self) weakSelf = self;
    [activityView showInView:[self activityContainerView] withText:activityText activity:YES completion:^{
        [[self voiceService] updateVoiceInfo:voiceInfo
                                  forSenseId:senseId
                                  completion:^(id response, NSError* error) {
                                      __strong typeof(weakSelf) strongSelf = weakSelf;
                                      if (error) {
                                          [voiceInfo setPrimaryUser:NO];
                                          // TODO: show error after completion!
                                          NSString* message = NSLocalizedString(@"voice.settings.update.error.primary-not-set", nil);
                                          [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                                              [strongSelf showUpdateError:message];
                                          }];
                                      } else {
                                          [[strongSelf tableView] reloadData];
                                          NSString* successText = NSLocalizedString(@"status.success", nil);
                                          [activityView dismissWithResultText:successText showSuccessMark:YES remove:YES completion:nil];
                                      }
                                  }];
    }];
}

#pragma mark - Volume

- (void)changeVolume {
    [[self delegate] showVolumeControlFromPresenter:self];
}

#pragma mark - Error

- (void)showUpdateError:(NSString*)message {
    NSString* title = NSLocalizedString(@"voice.settings.update.error.title", nil);
    [[self errorDelegate] showErrorWithTitle:title andMessage:message withHelpPage:nil fromPresenter:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
