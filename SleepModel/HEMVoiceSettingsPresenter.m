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

typedef NS_ENUM(NSUInteger, HEMVoiceSettingsRow){
    HEMVoiceSettingsRowPrimaryUser = 0,
    HEMVoiceSettingsRowCount
};

static CGFloat const kHEMVoiceFootNoteHorzMargins = 24.0f;
static CGFloat const kHEMVoiceFootNoteVertMargins = 12.0f;

@interface HEMVoiceSettingsPresenter() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) UIView* activityContainerView;

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
    [self setTableView:tableView];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    [navItem setTitle:NSLocalizedString(@"settings.voice", nil)];
}

- (void)bindWithActivityContainer:(UIView*)activityContainer {
    [self setActivityContainerView:activityContainer];
}

- (void)didRelayout {
    [super didRelayout];
    
    UIView* footer = [[self tableView] tableFooterView];
    [footer sizeToFit];
    [[self tableView] setTableFooterView:footer];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return HEMVoiceSettingsRowCount;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [HEMMainStoryboard settingsReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* title = nil;
    NSString* detail = nil;
    UIView* accessoryView = nil;
    
    switch ([indexPath row]) {
        default:
        case HEMVoiceSettingsRowPrimaryUser: {
            title = NSLocalizedString(@"voice.settings.primary-user", nil);
            
            SENSenseMetadata* senseMetadata = [[[self deviceService] devices] senseMetadata];
            SENSenseVoiceInfo* voiceInfo = [senseMetadata voiceInfo];
            UISwitch* primarySwitch = [UISwitch new];
            [primarySwitch setOn:[voiceInfo isPrimaryUser]];
            [primarySwitch setEnabled:![voiceInfo isPrimaryUser]];
            [primarySwitch setOnTintColor:[UIColor tintColor]];
            [primarySwitch addTarget:self
                              action:@selector(setAsPrimary:)
                    forControlEvents:UIControlEventTouchUpInside];
            
            accessoryView = primarySwitch;
            break;
        }
    }
    
    [[cell textLabel] setText:title];
    [[cell textLabel] setFont:[UIFont body]];
    [[cell textLabel] setTextColor:[UIColor grey6]];
    [[cell detailTextLabel] setText:detail];
    [[cell detailTextLabel] setFont:[UIFont body]];
    [[cell detailTextLabel] setTextColor:[UIColor grey4]];
    [cell setAccessoryView:accessoryView];
}

#pragma mark - Actions

- (void)setAsPrimary:(UISwitch*)primarySwitch {
    NSString* senseId = [[[[self deviceService] devices] senseMetadata] uniqueId];
    SENSenseVoiceInfo* voiceInfo = [SENSenseVoiceInfo new];
    [voiceInfo setPrimaryUser:YES];
    
    NSString* activityText = NSLocalizedString(@"voice.settings.update.status", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    __weak typeof(self) weakSelf = self;
    [activityView showInView:[self activityContainerView] withText:activityText activity:YES completion:^{
        [[self voiceService] updateVoiceInfo:voiceInfo
                                  forSenseId:senseId
                                  completion:^(id response, NSError* error) {
                                      if (error) {
                                          [primarySwitch setOn:NO];
                                          // TODO: show error after completion!
                                          NSString* message = NSLocalizedString(@"voice.settings.update.error.primary-not-set", nil);
                                          [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                                              __strong typeof(weakSelf) strongSelf = weakSelf;
                                              [strongSelf showUpdateError:message];
                                          }];
                                      } else {
                                          NSString* successText = NSLocalizedString(@"status.success", nil);
                                          [activityView dismissWithResultText:successText showSuccessMark:YES remove:YES completion:nil];
                                      }
                                  }];
    }];

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
