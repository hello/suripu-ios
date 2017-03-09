//
//  HEMSettingsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>

#import "Sense-Swift.h"

#import "HEMSettingsPresenter.h"
#import "HEMDeviceService.h"
#import "HEMExpansionService.h"
#import "HEMAccountService.h"
#import "HEMBreadcrumbService.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSettingsStoryboard.h"
#import "HEMTellAFriendItemProvider.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMStyle.h"

static CGFloat const HEMSettingsBottomMargin = 12.0f;
static CGFloat const HEMSettingsRowHeight = 56.0f;

typedef NS_ENUM(NSUInteger, HEMSettingsSection) {
    HEMSettingsSectionAccount = 0,
    HEMSettingsSectionMisc,
    HEMSettingsSections
};

typedef NS_ENUM(NSUInteger, HEMSettingsAccountRow) {
    HEMSettingsAccountRowProfile = 0,
    HEMSettingsAccountRowDevices,
    HEMSettingsAccountRowNotifications,
    HEMSettingsAccountRowExpansions,
    HEMSettingsAccountRowVoice,
    HEMSettingsAccountRowNightMode,
    HEMSettingsAccountRowCount
};

typedef NS_ENUM(NSUInteger, HEMSettingsMiscRow) {
    HEMSettingsMiscRowSupport = 0,
    HEMSettingsMiscRowTellFriend,
    HEMSettingsMiscRowCount
};

@interface HEMSettingsPresenter() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) HEMBreadcrumbService* breadcrumbService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, strong) NSArray<NSArray<NSNumber*>*>* sections;
@property (nonatomic, strong) UIView* versionView;
@property (nonatomic, weak) UILabel* versionLabel;

@end

@implementation HEMSettingsPresenter

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService
                     expansionService:(HEMExpansionService*)expansionService
                    breadCrumbService:(HEMBreadcrumbService*)breadcrumbService {
    if (self = [super init]) {
        _deviceService = deviceService;
        _expansionService = expansionService;
        _breadcrumbService = breadcrumbService;
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView {
    // header
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];
    [tableView setTableHeaderView:header];
    [tableView setTableFooterView:[self versionView]];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [self setTableView:tableView];
}

- (void)bindWithNavItem:(UINavigationItem*)navItem {
    [navItem setTitle:NSLocalizedString(@"settings.title", nil)];
}

- (void)bindWithActivityView:(HEMActivityIndicatorView*)activityView {
    [activityView start];
    [activityView setHidden:NO];
    [self setIndicatorView:activityView];
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    [self refreshSections];
}

#pragma mark - Presentation logic

- (UIView*)versionView {
    if (!_versionView) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *name = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *vers = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString *versionText = [NSString stringWithFormat:@"%@ %@", name, vers];
        
        UILabel *versionLabel = [UILabel new];
        [versionLabel setText:versionText];
        [versionLabel setContentMode:UIViewContentModeBottom];
        [versionLabel setTextAlignment:NSTextAlignmentCenter];
        [versionLabel setFont:[UIFont settingsHelpFont]];
        [versionLabel setTextColor:[UIColor textColor]];
        
        UIView* containerView = [UIView new];
        [containerView addSubview:versionLabel];
        [containerView setHidden:YES];
        
        _versionView = containerView;
        _versionLabel = versionLabel;
    }
    return _versionView;
}

- (void)layoutVersionView {
    [[self versionLabel] sizeToFit];
    
    CGRect versionLabelFrame = [[self versionLabel] frame];
    CGRect versionViewFrame = [[self versionView] frame];
    
    [[self versionView] sizeToFit];

    // can't always depend on content size
    NSInteger numberOfSections = [[self sections] count];
    CGFloat totalHeaderHeight = CGRectGetHeight([[[self tableView] tableHeaderView] bounds]);
    totalHeaderHeight += (numberOfSections - 1) * HEMSettingsHeaderFooterSectionHeight;
    
    CGFloat totalRowHeight = 0.0f;
    for (NSArray* rows in [self sections]) {
        totalRowHeight += [rows count] * HEMSettingsRowHeight;
    }
    
    CGFloat versionRequiredHeight = CGRectGetHeight([[self versionLabel] frame]);
    CGFloat contentHeight = totalHeaderHeight + totalRowHeight;
    
    CGFloat tableHeight = CGRectGetHeight([[self tableView] bounds]);
    CGFloat tableWidth = CGRectGetWidth([[self tableView] bounds]);
    CGFloat minSpacing = HEMSettingsHeaderFooterSectionHeight;
    
    CGFloat spaceAtBottom = tableHeight - contentHeight - HEMSettingsBottomMargin;
    CGFloat versionHeight = MAX(minSpacing + versionRequiredHeight, spaceAtBottom);
    
    versionLabelFrame.origin.y = versionHeight - versionRequiredHeight;
    versionLabelFrame.origin.x = (tableWidth - CGRectGetWidth([[self versionLabel] bounds])) / 2;
    [[self versionLabel] setFrame:versionLabelFrame];
    
    versionViewFrame.size.height = versionHeight + HEMSettingsBottomMargin;
    versionViewFrame.size.width = tableWidth;
    [[self versionView] setFrame:versionViewFrame];
    
    // must re-add it back to the tableview to have it update the content size
    [[self tableView] setTableFooterView:[self versionView]];
}

- (void)refreshSections {
    if (![self sections]) {
        [[self indicatorView] start];
        [[self indicatorView] setHidden:NO];
    }
    
    __weak typeof(self) weakSelf = self;
    void(^refresh)(SENSenseHardware version) = ^(SENSenseHardware version) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSMutableArray* sections = [NSMutableArray arrayWithCapacity:HEMSettingsSections];
        NSMutableArray* rows = nil;
        
        // account
        rows = [NSMutableArray arrayWithArray:@[@(HEMSettingsAccountRowProfile),
                                                @(HEMSettingsAccountRowDevices),
                                                @(HEMSettingsAccountRowNotifications)]];
        
        if ([[strongSelf expansionService] isEnabledForHardware:version]) {
            [rows addObject:@(HEMSettingsAccountRowExpansions)];
        }
        
        if (version == SENSenseHardwareVoice) {
            [rows addObject:@(HEMSettingsAccountRowVoice)];
        }
        
        [rows addObject:@(HEMSettingsAccountRowNightMode)];
        
        [sections addObject:rows];
        
        // misc
        [sections addObject:@[@(HEMSettingsMiscRowSupport),
                              @(HEMSettingsMiscRowTellFriend)]];
        
        [strongSelf setSections:sections];
        [[strongSelf indicatorView] stop];
        [[strongSelf indicatorView] setHidden:YES];
        [[strongSelf tableView] reloadData];
        [strongSelf layoutVersionView];
        [[strongSelf versionView] setHidden:NO];
    };
    
    SENSenseHardware savedVersion = [[self deviceService] savedHardwareVersion];
    if (savedVersion != SENSenseHardwareUnknown) {
        refresh (savedVersion);
    } else {
        [[self deviceService] refreshMetadata:^(SENPairedDevices * devices, NSError * error) {
            refresh ([[devices senseMetadata] hardwareVersion]);
        }];
    }
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSArray<NSNumber*>* rows = [self sections][section];
    
    if (row >= [rows count]) {
        return nil;
    }
    
    NSNumber* rowType = rows[row];
    if (section == HEMSettingsSectionAccount) {
        switch ([rowType unsignedIntegerValue]) {
            default:
            case HEMSettingsAccountRowProfile:
                return NSLocalizedString(@"settings.account", nil);
            case HEMSettingsAccountRowDevices:
                return NSLocalizedString(@"settings.devices", nil);
            case HEMSettingsAccountRowNotifications:
                return NSLocalizedString(@"settings.notifications", nil);
            case HEMSettingsAccountRowExpansions:
                return NSLocalizedString(@"settings.expansions", nil);
            case HEMSettingsAccountRowVoice:
                return NSLocalizedString(@"settings.voice", nil);
            case HEMSettingsAccountRowNightMode:
            return NSLocalizedString(@"settings.night-mode", nil);
        }
    } else {
        switch ([rowType unsignedIntegerValue]) {
            default:
            case HEMSettingsMiscRowSupport:
                return NSLocalizedString(@"settings.support", nil);
            case HEMSettingsMiscRowTellFriend:
                return  NSLocalizedString(@"settings.tell-a-friend", nil);
        }
    }
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray<NSNumber*>* rows = [self sections][section];
    return [rows count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case HEMSettingsSectionMisc:
            return HEMSettingsHeaderFooterSectionHeight;
        case HEMSettingsSectionAccount:
        default:
            return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = [HEMSettingsStoryboard settingsCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSArray<NSNumber*>* rows = [self sections][section];
    
    if (row >= [rows count]) {
        return;
    }

    [cell setBackgroundColor:[UIColor whiteColor]];
    [[cell textLabel] setText:[self titleForRowAtIndexPath:indexPath]];
    [[cell textLabel] setFont:[UIFont settingsTableCellFont]];
    [[cell textLabel] setTextColor:[UIColor settingsTextColor]];
    [cell showStyledAccessoryViewIfNone];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSArray* rows = [self sections][section];
    
    if (section == HEMSettingsSectionMisc
        && [rows[row] unsignedIntegerValue] == HEMSettingsMiscRowTellFriend) {
        [self tellAFriend];
    } else if (row < [rows count]) {
        NSNumber* rowType = rows[row];
        HEMSettingsCategory category = [self categoryForSection:section andRowType:rowType];
        [[self delegate] didSelectSettingsCategory:category fromPresenter:self];
    }
}

#pragma mark - Actions

- (HEMSettingsCategory)categoryForSection:(NSInteger)section andRowType:(NSNumber*)rowType {
    if (section == HEMSettingsSectionAccount) {
        switch ([rowType unsignedIntegerValue]) {
            default:
            case HEMSettingsAccountRowProfile:
                return HEMSettingsCategoryProfile;
            case HEMSettingsAccountRowDevices:
                return HEMSettingsCategoryDevices;
            case HEMSettingsAccountRowNotifications:
                return HEMSettingsCategoryNotifications;
            case HEMSettingsAccountRowExpansions:
                return HEMSettingsCategoryExpansions;
            case HEMSettingsAccountRowVoice:
                return HEMSettingsCategoryVoice;
            case HEMSettingsAccountRowNightMode:
                return HEMSettingsCategoryNightMode;
        }
    } else {
        switch ([rowType unsignedIntegerValue]) {
            default:
            case HEMSettingsMiscRowSupport:
                return HEMSettingsCategorySupport;
            case HEMSettingsMiscRowTellFriend:
                return HEMSettingsCategoryTellFriend;
        }
    }
}

- (void)tellAFriend {
    [SENAnalytics track:HEMAnalyticsEventTellAFriendTapped];
    
    NSString *subject = NSLocalizedString(@"settings.tell-a-friend.subject", nil);
    NSString *body = NSLocalizedString(@"settings.tell-a-friend.body", nil);
    HEMTellAFriendItemProvider *itemProvider = [[HEMTellAFriendItemProvider alloc] initWithSubject:subject
                                                                                              body:body];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[itemProvider]
                                                                                         applicationActivities:nil];
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType,
                                                            BOOL completed,
                                                            NSArray *returnedItems,
                                                            NSError *error) {
        if (error) {
            DDLogError(@"Could not complete share action: %@", error);
        }
        
        if (completed) {
            NSString *type = activityType ?: @"Unknown";
            [SENAnalytics track:HEMAnalyticsEventTellAFriendCompleted
                     properties:@{HEMAnalyticsEventTellAFriendCompletedPropType : type}];
        }
    }];
    
    [[self delegate] showController:activityViewController fromPresenter:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
