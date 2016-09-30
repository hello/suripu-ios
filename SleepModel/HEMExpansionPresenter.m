//
//  HEMExpansionPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 9/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENExpansion.h>

#import <SVWebViewController/SVModalWebViewController.h>

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
static CGFloat const kHEMExpansionConnectFinishDelay = 1.0f;

@interface HEMExpansionPresenter() <
    UITableViewDelegate,
    UITableViewDataSource,
    UIWebViewDelegate
>

@property (nonatomic, weak) SENExpansion* expansion;
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

@end

@implementation HEMExpansionPresenter

- (instancetype)initWithExpansionService:(HEMExpansionService*)service
                            forExpansion:(SENExpansion*)expansion {
    if (self = [super init]) {
        _expansionService = service;
        _expansion = expansion;
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
    [[headerView subtitleLabel] setText:[[self expansion] serviceName]];
    
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

- (void)hideConnectButtonIfConnected {
    if ([[self expansionService] isConnected:[self expansion]]) {
        CGFloat height = CGRectGetHeight([[self connectContainer] bounds]);
        [[self connectBottomConstraint] setConstant:-height];
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

- (void)wasRemovedFromParent {
    [super wasRemovedFromParent];
    if (_navBar) {
        [_navBar setShadowImage:[UIImage imageNamed:@"navBorder"]];
    }
}

- (void)grabConfigurations:(void(^)(void))completion {
    if (![[self expansionService] isConnected:[self expansion]]) {
        DDLogVerbose(@"skipping retrieval of configurations, not connected yet");
        if (completion) {
            completion ();
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[self expansionService] getConfigurationsForExpansion:[self expansion]
                                                completion:^(NSArray<SENExpansionConfig *> * configs, NSError * error) {
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
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
                                                }];
}

- (void)refreshRows:(BOOL)connected {
    NSMutableArray* rows = [NSMutableArray arrayWithCapacity:3];
    if (connected) {
        [rows addObject:@(HEMExpansionRowTypeEnable)];
        [rows addObject:@(HEMExpansionRowTypeConfiguration)];
        [rows addObject:@(HEMExpansionRowTypeRemove)];
    } else {
        // TODO: add this later
//        [rows addObject:@(HEMExpansionRowTypePermissions)];
    }
    [self setRows:rows];
}

- (NSString*)configurationName {
    NSString* type = [[[self expansion] category] lowercaseString];
    NSString* configNameFormat = @"expansion.configuration.name.%@";
    NSString* configNameKey = [NSString stringWithFormat:configNameFormat, type];
    NSString* configName = NSLocalizedString(configNameKey, nil);
    if ([configName isEqualToString:configNameKey]) {
        configName = NSLocalizedString(@"expansion.configuration.name.generic", nil);
    }
    return configName;
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
        case HEMExpansionRowTypeConfiguration:
            reuseId = [HEMMainStoryboard configReuseIdentifier];
            break;
        case HEMExpansionRowTypePermissions:
        case HEMExpansionRowTypeRemove:
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
            [self showRemoveAccessConfirmation];
            break;
        case HEMExpansionRowTypeConfiguration:
            [self showConfigurationOptions];
            break;
        default:
            break;
    }
}

#pragma mark - Display methods for cells

- (void)configureEnableCell:(HEMBasicTableViewCell*)cell {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[cell customTitleLabel] setText:NSLocalizedString(@"expansion.action.enable", nil)];
    [[cell infoButton] addTarget:self
                          action:@selector(showEnableInfo)
                forControlEvents:UIControlEventTouchUpInside];
    
    BOOL isEnabled = [[self expansion] state] == SENExpansionStateConnectedOn;
    UISwitch* enableSwitch = (UISwitch*) [cell customAccessoryView];
    [enableSwitch setOnTintColor:[UIColor tintColor]];
    [enableSwitch setOn:isEnabled];
    [enableSwitch addTarget:self
                     action:@selector(toggleEnable:)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureConfigurationCell:(HEMBasicTableViewCell*)cell {
    SENExpansionConfig* config = [[self configurations] firstObject];
    NSString* selectedName = [config localizedName];
    if (!selectedName) {
        selectedName = NSLocalizedString(@"empty-data", nil);
    }
    [[cell customTitleLabel] setText:[self configurationName]];
    [[cell customDetailLabel] setText:[config localizedName]];
    [[cell customDetailLabel] setFont:[UIFont body]];
    [[cell customDetailLabel] setTextColor:[UIColor grey3]];
}

- (void)configureRemoveAccessCell:(HEMBasicTableViewCell*)cell {
    [cell setCustomAccessoryView:nil];
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
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.no", nil) style:HEMAlertViewButtonStyleRoundRect action:nil];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.yes", nil) style:HEMAlertViewButtonStyleBlueText action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf removeAccess];
    }];
    
    [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
}

- (void)removeAccess {
    NSString* statusText = NSLocalizedString(@"expansion.status.removing-access", nil);
    __weak typeof(self) weakSelf = self;
    [self showActivity:statusText completion:^{
        [[self expansionService] removeExpansion:[self expansion] completion:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                // TODO: show error
                [strongSelf dismissActivitySucessfully:NO completion:nil];
            } else {
                [[strongSelf delegate] removedAccessFrom:strongSelf];
                [strongSelf dismissActivitySucessfully:YES completion:nil];
            }
        }];
    }];
}

- (void)connect {
    NSURLRequest* request = [[self expansionService] authorizationRequestForExpansion:[self expansion]];
    
    SVModalWebViewController *webViewController =
        [[SVModalWebViewController alloc] initWithURLRequest:request];
    
    [webViewController setWebViewDelegate:self];
    
    UINavigationBar* navBar = [webViewController navigationBar];
    [navBar setBarTintColor:[UIColor navigationBarColor]];
    [navBar setTranslucent:NO];
    // show default shadow / divider
    [navBar setClipsToBounds:NO];
    [navBar setShadowImage:nil];
    
    UIToolbar* toolBar = [webViewController toolbar];
    [toolBar setTintColor:[UIColor tintColor]];
    [toolBar setTranslucent:NO];
    
    [[self delegate] showController:webViewController onRootController:NO fromPresenter:self];
}

- (void)showEnableInfo {
    //TODO: show info
}

- (void)toggleEnable:(UISwitch*)enableSwitch {
    BOOL enabled = [enableSwitch isOn];
    BOOL currentEnabled = [[self expansion] state] == SENExpansionStateConnectedOn;
    if (enabled != currentEnabled) {
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
                    // TODO: show error
                    [strongSelf dismissActivitySucessfully:NO completion:nil];
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
                                               // TODO: show error
                                           } else {
                                               [strongSelf setSelectedConfig:configuration];
                                               [strongSelf setExpansion:expansion];
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
                    [strongSelf dismissActivitySucessfully:numberOfConfigs > 0 completion:^{
                        // TODO: show an error
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
    HEMActionSheetViewController* sheet = [HEMMainStoryboard instantiateActionSheetViewController];
    NSString* configurationName = [self configurationName];
    NSString* titleFormat = NSLocalizedString(@"expansion.configuration.options.title.format", nil);
    [sheet setTitle:[[NSString stringWithFormat:titleFormat, configurationName] uppercaseString]];
    
    __weak typeof (self) weakSelf = self;
    
    for (SENExpansionConfig* config in [self configurations]) {
        [sheet addOptionWithTitle:[config localizedName]
                       titleColor:[UIColor grey7]
                      description:nil
                        imageName:nil
                           action:^{
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               [strongSelf useConfiguration:config];
                           }];
    }
    
    [[self delegate] showController:sheet onRootController:YES fromPresenter:self];
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

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    DDLogVerbose(@"loading web request %@", [request URL]);
    BOOL finished = [[self expansionService] hasExpansion:[self expansion]
                                         connectedWithURL:[request URL]];
    if (finished) {
        [self refreshRows:YES];
        [[self tableView] reloadData];
        
        __weak typeof(self) weakSelf = self;
        int64_t delayInSecs = (int64_t) kHEMExpansionConnectFinishDelay* NSEC_PER_SEC;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[strongSelf delegate] dismissModalControllerFromPresenter:self];
            [[strongSelf expansionService] refreshExpansion:[strongSelf expansion] completion:^(SENExpansion * expansion, NSError * error) {
                __weak typeof(weakSelf) strongSelf = weakSelf;
                if (error) {
                    // TODO: show error
                } else {
                    [strongSelf setExpansion:expansion];
                    [strongSelf hideConnectButtonIfConnected];
                    [strongSelf showAvailableConfigurations];
                }
            }];
        });
    }
    
    return YES;
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
