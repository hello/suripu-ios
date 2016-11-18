//
//  HEMExpansionPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 9/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENExpansion.h>

#import "SENRemoteImage+HEMDeviceSpecific.h"

#import "HEMExpansionPresenter.h"
#import "HEMExpansionService.h"
#import "HEMExpansionHeaderView.h"
#import "HEMBasicTableViewCell.h"
#import "HEMURLImageView.h"
#import "HEMActionButton.h"
#import "HEMMainStoryboard.h"
#import "HEMActivityCoverView.h"
#import "HEMActionSheetViewController.h"
#import "HEMAlertViewController.h"
#import "HEMStyle.h"

typedef NS_ENUM(NSUInteger, HEMExpansionRowType) {
    HEMExpansionRowTypePermissions = 0,
    HEMExpansionRowTypeEnable,
    HEMExpansionRowTypeRemove,
    HEMExpansionRowTypeConfiguration
};

static CGFloat const kHEMExpansionHeaderIconBorder = 0.5f;
static CGFloat const kHEMExpansionHeaderIconCornerRadius = 5.0f;

@interface HEMExpansionPresenter() <
    UITableViewDelegate,
    UITableViewDataSource
>

@property (nonatomic, strong) SENExpansion* expansion;
@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) HEMActionButton* connectButton;
@property (nonatomic, weak) UIView* connectContainer;
@property (nonatomic, weak) NSLayoutConstraint* connectBottomConstraint;
@property (nonatomic, strong) NSArray<NSNumber*>* rows;
@property (nonatomic, weak) UIView* rootView;
@property (nonatomic, weak) HEMActivityCoverView* activityCoverView;
@property (nonatomic, strong) NSArray<SENExpansionConfig*>* configurations;
@property (nonatomic, weak) UINavigationBar* navBar;
@property (nonatomic, strong) SENExpansionConfig* selectedConfig;
@property (nonatomic, copy) NSString* configurationName;
@property (nonatomic, assign, getter=isLoadingConfigs) BOOL loadingConfigs;
@property (nonatomic, assign, getter=isSwitchEnabled) BOOL switchEnabled;

@end

@implementation HEMExpansionPresenter

- (instancetype)initWithExpansionService:(HEMExpansionService*)service
                            forExpansion:(SENExpansion*)expansion {
    if (self = [super init]) {
        _expansionService = service;
        _expansion = expansion;
        _configurationName = [service configurationNameForExpansion:expansion];
        [self refreshRows:[service isConnected:expansion]];
        [self grabConfigurations:nil];
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView {
    [tableView setAlwaysBounceVertical:NO];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setTableFooterView:[UIView new]];
    [self setTableView:tableView];
    
    NSString* iconUri = [[[self expansion] remoteIcon] uriForCurrentDevice];
    
    HEMExpansionHeaderView* headerView = [self headerView];
    [[[headerView urlImageView] layer] setCornerRadius:kHEMExpansionHeaderIconCornerRadius];
    [[headerView urlImageView] setBackgroundColor:[UIColor grey3]];
    [[headerView urlImageView] setImageWithURL:iconUri];
    [[headerView urlImageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[headerView urlImageView] setClipsToBounds:YES];
    [[[headerView urlImageView] layer] setBorderWidth:kHEMExpansionHeaderIconBorder];
    [[[headerView urlImageView] layer] setBorderColor:[[UIColor grey2] CGColor]];
    
    [[headerView titleLabel] setTextColor:[UIColor grey7]];
    [[headerView titleLabel] setFont:[UIFont bodyBold]];
    [[headerView titleLabel] setText:[[self expansion] deviceName]];
    
    [[headerView subtitleLabel] setTextColor:[UIColor grey5]];
    [[headerView subtitleLabel] setFont:[UIFont bodySmall]];
    [[headerView subtitleLabel] setText:[[self expansion] companyName]];
    
    [[headerView descriptionLabel] setFont:[UIFont body]];
    [[headerView descriptionLabel] setTextColor:[UIColor grey5]];
    [[headerView descriptionLabel] setText:[[self expansion] expansionDescription]];
}

- (void)bindWithConnectContainer:(UIView*)container
             andBottomConstraint:(NSLayoutConstraint*)bottomConstraint
                      withButton:(HEMActionButton*)connectButton {
    [connectButton addTarget:self
                      action:@selector(connect)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self setConnectContainer:container];
    [self setConnectButton:connectButton];
    [self setConnectBottomConstraint:bottomConstraint];
    [self hideConnectButtonIfConnected];
}

- (void)bindWithNavBar:(UINavigationBar*)navBar {
    [navBar setShadowImage:[UIImage new]];
    [self setNavBar:navBar];
}

- (void)bindWithRootView:(UIView *)view {
    [self setRootView:view];
}

- (BOOL)hasNavBar {
    return [self navBar] != nil;
}

- (void)reload:(SENExpansion*)expansion {
    [self setExpansion:expansion];
    [self refreshRows:[[self expansionService] isConnected:expansion]];
    [self grabConfigurations:nil];
    [self hideConnectButtonIfConnected];
}

#pragma mark - Presenter Events

- (void)wasRemovedFromParent {
    [super wasRemovedFromParent];
    if (_navBar) {
        [_navBar setShadowImage:[UIImage imageNamed:@"navBorder"]];
    }
}

#pragma mark -

- (void)hideConnectButtonIfConnected {
    if ([[self expansionService] isConnected:[self expansion]]) {
        CGFloat height = CGRectGetHeight([[self connectContainer] bounds]);
        [[self connectBottomConstraint] setConstant:-height];
        [[self connectContainer] layoutIfNeeded];
    }
}

- (HEMExpansionHeaderView*)headerView {
    HEMExpansionHeaderView* expansionHeader = nil;
    UIView* headerView = [[self tableView] tableHeaderView];
    if ([headerView isKindOfClass:[HEMExpansionHeaderView class]]) {
        expansionHeader = (id) headerView;
    }
    return expansionHeader;
}

- (void)grabConfigurations:(void(^)(void))completion {
    if (![[self expansionService] isConnected:[self expansion]]) {
        DDLogVerbose(@"skipping retrieval of configurations, not connected yet");
        if (completion) {
            completion ();
        }
        return;
    }
    
    [self setLoadingConfigs:YES];
    
    __weak typeof(self) weakSelf = self;
    void(^finish)(NSArray<SENExpansionConfig*>* configs) = ^(NSArray<SENExpansionConfig*>* configs) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setLoadingConfigs:NO];
        [strongSelf setConfigurations:configs];
        if (configs) {
            for (SENExpansionConfig* config in configs) {
                if ([config isSelected]) {
                    [strongSelf setSelectedConfig:config];
                    break;
                }
            }
        }
        [[strongSelf tableView] reloadData];
        if (completion) {
            completion();
        }
    };
    
    HEMExpansionService* service = [self expansionService];
    [service getConfigurationsForExpansion:[self expansion]
                                completion:^(NSArray<SENExpansionConfig*>* configs, NSError * error) {
                                    finish(configs);
                                    // what if there's an error here?
                                }];
}

- (void)refreshRows:(BOOL)connected {
    NSMutableArray* rows = [NSMutableArray arrayWithCapacity:3];
    if (connected) {
        if ([[self expansion] state] != SENExpansionStateNotConfigured
            || [self selectedConfig]) {
            [rows addObject:@(HEMExpansionRowTypeEnable)];
        }
        [rows addObject:@(HEMExpansionRowTypeConfiguration)];
        [rows addObject:@(HEMExpansionRowTypeRemove)];
    }
    [self setRows:rows];
}
#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self rows] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* rowType = [self rows][[indexPath row]];
    NSString* reuseId = nil;
    switch ([rowType unsignedIntegerValue]) {
        case HEMExpansionRowTypeEnable:
            reuseId = [HEMMainStoryboard toggleReuseIdentifier];
            break;
        case HEMExpansionRowTypeRemove:
            reuseId = [HEMMainStoryboard plainReuseIdentifier];
            break;
        case HEMExpansionRowTypeConfiguration:
            reuseId = [HEMMainStoryboard configReuseIdentifier];
            break;
        case HEMExpansionRowTypePermissions:
        default:
            reuseId = [HEMMainStoryboard textReuseIdentifier];
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* rowType = [self rows][[indexPath row]];
    HEMBasicTableViewCell* basicCell = (id)cell;
    [[basicCell customTitleLabel] setFont:[UIFont body]];
    [[basicCell customTitleLabel] setTextColor:[UIColor grey6]];
    
    switch ([rowType unsignedIntegerValue]) {
        case HEMExpansionRowTypePermissions: {
            [[basicCell customTitleLabel] setText:NSLocalizedString(@"expansion.action.permissions", nil)];
            break;
        }
        case HEMExpansionRowTypeEnable: {
            [self configureEnableCell:basicCell];
            break;
        }
        case HEMExpansionRowTypeConfiguration: {
            [self configureConfigurationCell:basicCell];
            break;
        }
        case HEMExpansionRowTypeRemove:
            [self configureRemoveAccessCell:basicCell];
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNumber* rowType = [self rows][[indexPath row]];
    switch ([rowType unsignedIntegerValue]) {
        case HEMExpansionRowTypeRemove:
            return [self showRemoveAccessConfirmation];
        case HEMExpansionRowTypeConfiguration: {
            if (![self isLoadingConfigs]) {
                return [self showConfigurationOptions];
            } else {
                return;
            }
        }
        default:
            return;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Display methods for cells

- (void)configureEnableCell:(HEMBasicTableViewCell*)cell {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[cell customTitleLabel] setText:NSLocalizedString(@"expansion.action.enable", nil)];
    
    if ([[self delegate] canShowInfoAboutExpansion:[self expansion] fromPresenter:self]) {
        [[cell infoButton] addTarget:self
                              action:@selector(showEnableInfo)
                    forControlEvents:UIControlEventTouchUpInside];
    } else {
        [[cell infoButton] setHidden:YES];
    }
    
    BOOL isEnabled = [[self expansion] state] == SENExpansionStateConnectedOn;
    UISwitch* enableSwitch = (UISwitch*) [cell customAccessoryView];
    [enableSwitch setOnTintColor:[UIColor tintColor]];
    [enableSwitch setOn:isEnabled];
    [enableSwitch addTarget:self
                     action:@selector(toggleEnable:)
           forControlEvents:UIControlEventValueChanged];
    [self setSwitchEnabled:isEnabled];
}

- (void)configureConfigurationCell:(HEMBasicTableViewCell*)cell {
    NSString* selectedName = [[self selectedConfig] localizedName];
    UIColor* nameColor = [UIColor grey3];
    if (!selectedName) {
        if ([[self configurations] count] == 0) {
            selectedName = NSLocalizedString(@"empty-data", nil);
        } else { 
            selectedName = NSLocalizedString(@"expansion.config.select", nil);
            nameColor = [UIColor tintColor];
        }
    }
    
    [[cell customTitleLabel] setText:[self configurationName]];
    [[cell customDetailLabel] setText:selectedName];
    [[cell customDetailLabel] setFont:[UIFont body]];
    [[cell customDetailLabel] setTextColor:nameColor];
    [cell showActivity:[self isLoadingConfigs]];
    
    if ([self isLoadingConfigs]) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } else {
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
}

- (void)configureRemoveAccessCell:(HEMBasicTableViewCell*)cell {
    [[cell customTitleLabel] setText:NSLocalizedString(@"expansion.action.remove", nil)];
    [[cell customTitleLabel] setTextColor:[UIColor red6]];
}

#pragma mark - Actions

- (void)showRemoveAccessConfirmation {
    NSString* title = NSLocalizedString(@"expansion.configuration.removal.confirm.title", nil);
    NSString* message = NSLocalizedString(@"expansion.configuration.removal.confirm.message", nil);
    
    NSDictionary* messageAttrs = @{NSFontAttributeName : [UIFont dialogMessageFont],
                                   NSForegroundColorAttributeName : [UIColor blackColor]};
    NSAttributedString* attrMessage = [[NSAttributedString alloc] initWithString:message attributes:messageAttrs];
    
    HEMAlertViewController* dialogVC = [HEMAlertViewController new];
    [dialogVC setTitle:title];
    [dialogVC setAttributedMessage:attrMessage];
    
    __weak typeof(self) weakSelf = self;
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.delete", nil) style:HEMAlertViewButtonStyleRoundRect action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf removeAccess];
    }];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.cancel", nil) style:HEMAlertViewButtonStyleBlueText action:nil];
    
    [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
}

- (void)removeAccess {
    NSString* statusText = NSLocalizedString(@"expansion.status.removing-access", nil);
    __weak typeof(self) weakSelf = self;
    [self showActivity:statusText completion:^{
        [[self expansionService] removeExpansion:[self expansion] completion:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                [strongSelf dismissActivitySucessfully:NO completion:^{
                    [strongSelf showGenericError];
                }];
            } else {
                [[strongSelf delegate] removedAccessFrom:strongSelf];
                [strongSelf dismissActivitySucessfully:YES completion:nil];
            }
        }];
    }];
}

- (void)connect {
    [[self delegate] connectExpansionFromPresenter:self];
}

- (void)showEnableInfo {
    [[self delegate] showInfoAboutExpansion:[self expansion] fromPresenter:self];
}

- (void)toggleEnable:(UISwitch*)enableSwitch {
    BOOL enabled = [enableSwitch isOn];
    if ([self isSwitchEnabled] != enabled) {
        [self setSwitchEnabled:enabled];
        
        DDLogVerbose(@"toggling switch to %@", @(enabled));
        
        NSString* statusText = nil;
        if (enabled) {
            statusText = NSLocalizedString(@"expansion.status.enabling", nil);
        } else {
            statusText = NSLocalizedString(@"expansion.status.disabling", nil);
        }
        
        __weak typeof(self) weakSelf = self;
        [self showActivity:statusText completion:^{
            [[self expansionService] enable:enabled expansion:[self expansion] completion:^(NSError * error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (error) {
                    [enableSwitch setOn:!enabled];
                    [strongSelf setSwitchEnabled:!enabled];
                    
                    [strongSelf dismissActivitySucessfully:NO completion:^{
                        [strongSelf showGenericError];
                    }];
                } else {
                    [strongSelf dismissActivitySucessfully:YES completion:nil];
                }
            }];
        }];
    }
}

- (void)useConfiguration:(SENExpansionConfig*)configuration {
    NSString* activityTextFormat = NSLocalizedString(@"expansion.configuration.activity.updating-config.format", nil);
    NSString* activityText = [NSString stringWithFormat:activityTextFormat, [self configurationName]];
    
    __weak typeof(self) weakSelf = self;
    [self showActivity:activityText completion:^{
        [[self expansionService] setConfiguration:configuration
                                     forExpansion:[self expansion]
                                       completion:^(SENExpansion * expansion, NSError * error) {
                                           __strong typeof(weakSelf) strongSelf = weakSelf;
                                           if (error) {
                                               [strongSelf showGenericError];
                                           } else {
                                               [strongSelf setSelectedConfig:configuration];
                                               [strongSelf setExpansion:expansion];
                                               [strongSelf refreshRows:YES];
                                               [[strongSelf tableView] reloadData];
                                           }
                                           [strongSelf dismissActivitySucessfully:error == nil completion:nil];
                                       }];
    }];
}

- (void)showAvailableConfigurations {
    if ([[self configurations] count] == 0) {
        __weak typeof(self) weakSelf = self;
        NSString* activityText = NSLocalizedString(@"expansion.configuration.activity.loading-configs", nil);
        [self showActivity:activityText completion:^{
            [self grabConfigurations:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSInteger numberOfConfigs = [[strongSelf configurations] count];
                if (numberOfConfigs == 0) {
                    [strongSelf dismissActivitySucessfully:NO completion:^{
                        [strongSelf showNoConfigurationError];
                    }];
                } else if (numberOfConfigs == 1) {
                    [strongSelf useConfiguration:[[strongSelf configurations] firstObject]];
                } else {
                    // pop up choices
                    [strongSelf showConfigurationOptions];
                    [strongSelf dismissActivitySucessfully:NO completion:nil];
                }
            }];
        }];
    } else {
         [self showConfigurationOptions];
    }
}

- (void)showConfigurationOptions {
    if ([[self configurations] count] == 0) {
        return [self showNoConfigurationError];
    }
    
    HEMActionSheetViewController* sheet = [HEMMainStoryboard instantiateActionSheetViewController];
    NSString* configurationName = [self configurationName];
    NSString* titleFormat = NSLocalizedString(@"expansion.configuration.options.title.format", nil);
    [sheet setTitle:[[NSString stringWithFormat:titleFormat, configurationName] uppercaseString]];
    
    __weak typeof (self) weakSelf = self;
    
    for (SENExpansionConfig* config in [self configurations]) {
        BOOL selected = NO;
        // check against the selectedConfig in case the cached list of configs
        // has not reloaded in time after selection.
        if ([config isEqual:[self selectedConfig]]) {
            selected = YES;
        }
        [sheet addOptionWithTitle:[config localizedName]
                       titleColor:[UIColor grey7]
                      description:nil
                        imageName:nil
                         selected:selected
                           action:^{
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               [strongSelf useConfiguration:config];
                           }];
    }
    
    [[self delegate] showController:sheet fromPresenter:self];
}

#pragma mark - Activity

- (void)showActivity:(NSString*)text completion:(void(^)(void))completion {
    if ([[self activityCoverView] isShowing]) {
        [[self activityCoverView] updateText:text completion:^(BOOL finished) {
            if (completion) {
                completion ();
            }
        }];
    } else {
        HEMActivityCoverView* activityView = [HEMActivityCoverView new];
        [activityView showInView:[self rootView] withText:text activity:YES completion:completion];
        [self setActivityCoverView:activityView];
    }
}

- (void)dismissActivitySucessfully:(BOOL)success completion:(void(^)(void))completion {
    if ([[self activityCoverView] isShowing]) {
        NSString* text = nil;
        if (success) {
            text = NSLocalizedString(@"actions.done", nil);
        }
        
        [[self activityCoverView] dismissWithResultText:text
                                        showSuccessMark:success
                                                 remove:YES
                                             completion:completion];
    }
}

#pragma mark - Error

- (void)showGenericError {
    NSString* title = NSLocalizedString(@"expansion.error.setup.generic.title", nil);
    NSString* message = NSLocalizedString(@"expansion.error.setup.generic.message", nil);
    [[self errorDelegate] showErrorWithTitle:title
                                  andMessage:message
                                withHelpPage:nil
                               fromPresenter:self];
}

- (void)showNoConfigurationError {
    NSString* category = nil;
    switch ([[self expansion] type]) {
        case SENExpansionTypeLights:
            category = @"light";
            break;
        case SENExpansionTypeThermostat:
            category = @"thermostat";
        default:
            category = @"generic";
            break;
    }
    NSString* titleKey = [NSString stringWithFormat:@"expansion.error.setup.no-groups.%@.title", category];
    NSString* title = NSLocalizedString(titleKey, nil);
    
    NSString* messageKey = [NSString stringWithFormat:@"expansion.error.setup.no-groups.%@.message.format", category];
    NSString* messageFormat = NSLocalizedString(messageKey, nil);
    NSString* message = [NSString stringWithFormat:messageFormat, [[self expansion] companyName]];
    
    [[self errorDelegate] showErrorWithTitle:title
                                  andMessage:message
                                withHelpPage:nil
                               fromPresenter:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
